#define GPU_CODE 1
// # define CPU_CODE 1

int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths);

#ifdef CPU_CODE

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

#endif // CPU_CODE

#ifdef GPU_CODE


__global__ void find_core(int M, int* cores_exec_time_left, int diff, int last_pid_core, int last_core_exec_time_update,
                          int* curr_core_id, int* curr_min_exec_time) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < M) {
        int curr_core_exec_time_left = cores_exec_time_left[tid];

        // printf("TID: %d, curr_core_exec_time: %d Original - Diff: %d, Last_PID: %d, Last_Core_exec_time: %d\n",
        //          tid, curr_core_exec_time_left, diff, last_pid_core, last_core_exec_time_update);

        // Shoudl be done before diff sine technically, it should have already been added
        if (tid == last_pid_core) {
            // Last iteration, this core was chosen, therefore exec_time needs to be updated
            curr_core_exec_time_left += last_core_exec_time_update;
        }

        if (diff != 0) {
            // Update the exec time
            int tmp = curr_core_exec_time_left - diff;
            curr_core_exec_time_left = (tmp > 0) ? tmp : 0;
        }

        // printf("TID: %d, curr_core_exec_time: %d\n", tid, curr_core_exec_time_left);

        if(curr_core_exec_time_left < *curr_min_exec_time) {
            // printf("curr_min_exec_time is %d\n", *curr_min_exec_time);
            int old_val = atomicMin(curr_min_exec_time, curr_core_exec_time_left);

            if (old_val == curr_core_exec_time_left) {
                // Tie for same min exec time, break using core_id
                atomicMin(curr_core_id, tid);
                // printf("Tie for min exec time, TID %d\n", tid);
            }
            else if (old_val > curr_core_exec_time_left) {
                // New core has been selected, update the core_id
                *curr_core_id = tid;
                // printf("New core in kernel: %d\n", *curr_core_id);
            }
        }
        else if (curr_core_exec_time_left == *curr_min_exec_time) {
            // Tie for same min exec time, break using core_id
            atomicMin(curr_core_id, tid);
            // printf("Tie for min exec time, tid %d\n", tid);
        }

        cores_exec_time_left[tid] = curr_core_exec_time_left;
    }
}


int gpu_schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
    int turnaround = 0;
    int *curr_core_queue_lengths = (int*)calloc(M, sizeof(int));
    int diff = 0;
    int last_arrival_time = 0;
    int curr_arrival_time = 0;

    int int_max = INT_MAX;

    int last_pid_core = 0;
    int last_core_exec_time_update = 0;

    int n_blocks = ceil(float(M) / 1024);
    int *cores_exec_time_left;
    cudaMalloc(&cores_exec_time_left, M*sizeof(int));
    cudaMemset(cores_exec_time_left, 0, M*sizeof(int));

    int *curr_core_id;
    int *curr_min_exec_time;
    cudaMalloc(&curr_core_id, sizeof(int));
    cudaMalloc(&curr_min_exec_time, sizeof(int));

    int cpu_curr_core_id = -1;
    int cpu_curr_min_exec_time_left = -1;

    // printf("Starting PID loops\n");

    for(int pid=0; pid<N; pid++) {
        last_arrival_time = curr_arrival_time;
        curr_arrival_time = arrival_times[pid];
        diff = curr_arrival_time - last_arrival_time;

        // Set curr_min_exec_time on GPU to be INT_MAX
        cudaMemcpy(curr_min_exec_time, &int_max, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(curr_core_id, &int_max, sizeof(int), cudaMemcpyHostToDevice);

        // printf("Launching find_core kernel for PID %d\n", pid);
        find_core<<<n_blocks, 1024>>>(M, cores_exec_time_left, diff, last_pid_core, last_core_exec_time_update,
                                      curr_core_id, curr_min_exec_time);
        cudaDeviceSynchronize();

        // curr_core_id should now have the core selected
        cudaMemcpy(&cpu_curr_core_id, curr_core_id, sizeof(int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&cpu_curr_min_exec_time_left, curr_min_exec_time, sizeof(int), cudaMemcpyDeviceToHost);

        // printf("Kernel, cudaMemcpy calls completed\n");

        turnaround += (cpu_curr_min_exec_time_left + burst_times[pid]);

        // Add pid to the selected core schedule

        // Check if enough space is present in queue for the core
        int curr_length = cs_lengths[cpu_curr_core_id];
        // printf("Curr Length for core %d: %d\n", cpu_curr_core_id, curr_length);

        if (curr_length >= curr_core_queue_lengths[cpu_curr_core_id]) {
            curr_core_queue_lengths[cpu_curr_core_id] = curr_length*2;
            // printf("Reallocing space %d for core %d\n", curr_core_queue_lengths[cpu_curr_core_id], cpu_curr_core_id);
            cores_schedules[cpu_curr_core_id] = (int*)realloc(cores_schedules[cpu_curr_core_id],
                                                              curr_length*2);
        }

        cores_schedules[cpu_curr_core_id][curr_length] = pid;
        cs_lengths[cpu_curr_core_id] = curr_length+1;

        // Update exec_time of core
        last_pid_core = cpu_curr_core_id;
        last_core_exec_time_update = burst_times[pid];
    }

    // printf("Completed PID loop\n");
    return turnaround;
}

#endif // GPU_CODE

int schedule(int N, int M, int* arrival_times, int* burst_times, int** cores_schedules, int* cs_lengths) {
#ifdef CPU_CODE
    return cpu_schedule(N, M, arrival_times, burst_times, cores_schedules, cs_lengths);
#endif

#ifdef GPU_CODE
    return gpu_schedule(N, M, arrival_times, burst_times, cores_schedules, cs_lengths);
#endif
}
