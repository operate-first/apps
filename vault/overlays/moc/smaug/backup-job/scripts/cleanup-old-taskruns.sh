#!/bin/sh
set -e
NUM_TO_KEEP=$(cat /backup-job/OldJobsToKeepCount)
while read -r TASK; do
  while read -r TASK_TO_REMOVE; do
    test -n "${TASK_TO_REMOVE}" || continue;
    oc delete ${TASK_TO_REMOVE} \
        && echo "$(date -Is) TaskRun ${TASK_TO_REMOVE} deleted." \
        || echo "$(date -Is) Unable to delete TaskRun ${TASK_TO_REMOVE}.";
  done < <(oc get taskrun -l tekton.dev/task=${TASK} --sort-by=.metadata.creationTimestamp -o name | head -n -${NUM_TO_KEEP});
done < <(oc get taskrun -o go-template='{{range .items}}{{index .metadata.labels "tekton.dev/task"}}{{"\n"}}{{end}}' | uniq);
