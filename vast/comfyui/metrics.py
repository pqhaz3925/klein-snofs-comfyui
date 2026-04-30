"""ComfyUI metrics for vast-pyworker. Adapted from sdauto/metrics.py."""
import random
import time

from metrics import GenericMetrics


def calc_comfy_work(worker_payload):
    """Estimate work units for a ComfyUI workflow.

    The autoscaler only needs self-consistent magnitudes (load metrics never
    cross usecases). For lack of access to per-node info, we return a fixed
    magnitude; ComfyUI workflows tend to have similar runtime per workflow.
    """
    return 100_000


class Metrics(GenericMetrics):
    def __init__(self, id, master_token, control_server_url, send_server_data):
        self.tot_work_completed = 0
        self.finished_request_time = 0
        self.work_incoming = 0
        self.work_finished = 0
        self.work_errored = 0
        self.perf = 0.0
        super().__init__(id, master_token, control_server_url, send_server_data)

    def fill_data(self, data):
        self.fill_data_generic(data)

        ntime = time.time()
        elapsed = ntime - self.fill_data_lut
        if self.fill_data_lut == 0.0:
            elapsed = 1.0
        self.fill_data_lut = ntime
        self.cur_load = (self.work_incoming + self.work_errored) / elapsed
        data["cur_load"] = self.cur_load
        self.work_incoming = 0
        self.work_errored = 0
        self.cur_capacity_lastreport = self.work_finished

    def start_req(self, request):
        self.num_requests_recieved += 1
        self.num_requests_working += 1
        self.work_incoming += calc_comfy_work(request)

    def finish_req(self, request):
        self.num_requests_finished += 1
        self.num_requests_working -= 1
        self.finished_request_time += request["time_elapsed"]
        request_work = calc_comfy_work(request)

        alpha = 0.5
        cur_perf = (
            request_work / request["time_elapsed"]
            if request["time_elapsed"] != 0.0
            else 0.0
        )
        self.cur_perf = alpha * self.cur_perf + (1 - alpha) * cur_perf
        self.work_finished += request_work

    def error_req(self, request, code=None):
        self.num_requests_recieved -= 1
        self.num_requests_working -= 1
        self.work_incoming -= calc_comfy_work(request)
        self.work_errored += calc_comfy_work(request)

    def report_req_stats(self, log_data):
        self.curr_wait_time = log_data["wait_time"]
        self.overloaded = self.curr_wait_time > 30.0

    def send_data_condition(self):
        return (
            ((random.randint(0, 9) == 3) or (self.work_finished != self.cur_capacity_lastreport))
            and self.model_loaded
        )
