let s:env = "!ssh ubuntu@terraform -C 'cd ecs-codepipeline;"

function Update()
  let l:cmd = "git pull"
  execute s:env . l:cmd . "'"
endfunction

function Cf_create(stack_name)
  let l:cmd = "cd cloudformation;bash script/create_stack "
  execute s:env . l:cmd . a:stack_name . "'"
endfunction

function Cf_list()
  let l:cmd = "cd cloudformation;bash scripts/list_stacks"
  execute s:env . l:cmd . "'"
endfunction
