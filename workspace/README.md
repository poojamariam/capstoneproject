kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"2222":"devops/gitlab-gitlab-shell:22"}}'
