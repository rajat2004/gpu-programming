int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths);


int schedule_on_core(int core_id, int pid, int arrival_time, int burst_time,
                      int* cores_exec_time_left, int** cores_schedules, int* cs_lengths, int* curr_core_queue_lengths) {
    // Check if enough space is present in queue for the core
    int curr_length = cs_lengths[core_id];

    if (curr_length >= curr_core_queue_lengths[core_id]) {
        curr_core_queue_lengths[core_id] = curr_length*2;
        // printf("Reallocing space %d for core %d\n", curr_core_queue_lengths[core_id], core_id);
        cores_schedules[core_id] = (int*)realloc(cores_schedules[core_id], curr_core_queue_lengths[core_id]);
    }

    // int turnaround_core = cores_exec_time_left[core_id] + burst_time;
    cores_exec_time_left[core_id] += burst_time;
    cores_schedules[core_id][curr_length] = pid;
    cs_lengths[core_id]=curr_length + 1;

    return cores_exec_time_left[core_id];
}

int cpu_schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
    int last_arrival_time = 0;
    int curr_arrival_time = 0;
    int diff = 0;
    int curr_core_id;
    int curr_min_exec_time;
    int flag = 0;

    int *cores_exec_time_left = (int*)calloc(M, sizeof(int));
    int *curr_core_queue_lengths = (int*)calloc(M, sizeof(int));

    int turnaround = 0;

    for(int pid=0; pid<N; pid++) {
        // Iterates over the processes, sorted in ascending order of arrival time
        // printf("PID %d\n", pid);

        last_arrival_time = curr_arrival_time;
        curr_arrival_time = arrival_times[pid];
        diff = curr_arrival_time - last_arrival_time;

        flag = 0;
        curr_min_exec_time = INT_MAX;
        curr_core_id = -1;

        for(int core_id = 0; core_id<M; core_id++) {
            if (diff != 0) {
                // printf("Updating exec_time of core %d by %d\n", core_id, diff);
                cores_exec_time_left[core_id] = (cores_exec_time_left[core_id] > diff) ? (cores_exec_time_left[core_id] - diff):0;
            }

            if(cores_exec_time_left[core_id] == 0) {
                // printf("Core: %d, PID: %d, Exec Time 0\n", core_id, pid);
                turnaround += schedule_on_core(core_id, pid, arrival_times[pid], burst_times[pid],
                                               cores_exec_time_left, cores_schedules, cs_lengths, curr_core_queue_lengths);
                flag = 1;
                break;
            }

            if (curr_min_exec_time > cores_exec_time_left[core_id]) {
                curr_core_id = core_id;
                curr_min_exec_time = cores_exec_time_left[core_id];
                // printf("New min core %d with exec_time_left %d\n", core_id, curr_min_exec_time);
            }
            // else if (curr_min_exec_time == cores_exec_time_left[core_id])

        }

        if (flag==0) {
            // printf("Core: %d, PID: %d\n", curr_core_id, pid);
            turnaround += schedule_on_core(curr_core_id, pid, arrival_times[pid], burst_times[pid],
                                           cores_exec_time_left, cores_schedules, cs_lengths, curr_core_queue_lengths);
        }

        // printf("PID %d finished\n", pid);
    }
    return turnaround;
}

int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
    return cpu_schedule(N, M, arrival_times, burst_times, cores_schedules, cs_lengths);
}
