#include <thrust/device_vector.h>

int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths);

struct advance_time {
    const int diff_;
    advance_time(int diff) : diff_(diff){}

    __host__ __device__
    int operator()(const int& x) const {
        return (x > diff_) ? (x-diff_) : 0;
    }
};


int gpu_schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
    thrust::device_vector<int> cores_exec_time_left(M, 1);

    int curr_arrival_time = 0;
    int last_arrival_time = 0;
    int diff = 0;

    int turnaround = 0;

    int *curr_core_queue_lengths = (int*)calloc(M, sizeof(int));
    memset(cs_lengths, 0, M*sizeof(int));

    for(int pid=0; pid<N; pid++) {
        last_arrival_time = curr_arrival_time;
        curr_arrival_time = arrival_times[pid];
        diff = curr_arrival_time - last_arrival_time;

        if (diff != 0)
            thrust::transform(cores_exec_time_left.begin(), cores_exec_time_left.end(),
                                cores_exec_time_left.begin(), advance_time(diff));

        int core_id = thrust::min_element(cores_exec_time_left.begin(), cores_exec_time_left.end())
                      - cores_exec_time_left.begin();

        int curr_length = cs_lengths[core_id];

        if (curr_length >= curr_core_queue_lengths[core_id]) {
            curr_core_queue_lengths[core_id] = curr_length + 10;
            // printf("Reallocing space %d for core %d\n", curr_core_queue_lengths[core_id], core_id);
            int* new_arr = (int*)realloc(cores_schedules[core_id], (curr_length + 10)*sizeof(int));
            if (new_arr != NULL) {
                // realloc worked
                cores_schedules[core_id] = new_arr;
            }
            else {
                // realloc failed, try malloc once?
                new_arr = (int*)malloc((curr_length + 10)*sizeof(int));
                if(new_arr != NULL) {
                    // malloc worked, now memcpy and update ptr
                    memcpy(new_arr, cores_schedules[core_id], curr_length*sizeof(int));
                    free(cores_schedules[core_id]);
                    cores_schedules[core_id] = new_arr;
                }
                else {
                    // malloc also failed, probably best to exit now, since anyways, there'll be a seg fault
                    printf("Error allocating memory, exiting!\n");
                    exit(1);
                }

            } // end of realloc-failure handle
        } // end of mem allocation handling

        cores_schedules[core_id][curr_length] = pid;
        cs_lengths[core_id]=curr_length + 1;

        int proc_turnaround = cores_exec_time_left[core_id] + burst_times[pid];
        cores_exec_time_left[core_id] = proc_turnaround;
        turnaround += proc_turnaround;
    }

    return turnaround;
}


int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
    return gpu_schedule(N, M, arrival_times, burst_times, cores_schedules, cs_lengths);
}
