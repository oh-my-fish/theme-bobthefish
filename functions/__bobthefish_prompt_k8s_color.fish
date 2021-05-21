function __bobthefish_prompt_k8s_color -S -d 'Determine Kubernetes prompt color based on the current context and namespace'
    for i in $color_k8s
        echo $i
    end
end
