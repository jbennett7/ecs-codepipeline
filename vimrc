function Update()
  !ssh ubuntu@terraform -C 'cd ecs-codepipeline;git pull'
endfunction

function Status()
  !ssh ubuntu@terraform -C 'cd ecs-codepipeline;git status'
endfunction

function Cf_create(stack_name)
  execute "!ssh ubuntu@terraform -C 'cd ecs-codepipeline/cloudformation;bash script/create_stack " . stack_name
endfunction
