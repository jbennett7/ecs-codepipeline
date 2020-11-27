let s:env = "!ssh ubuntu@terraform -C 'cd ecs-codepipeline;"

function Update()
  let l:cmd = "git pull"
  execute s:env . l:cmd . "'"
endfunction

function Cf_create(stack_name)
  let l:cmd = "cd cloudformation;bash scripts/create_stack "
  execute s:env . l:cmd . a:stack_name . "'"
endfunction
command! -nargs=+ -complete=command Cfcreate call Cf_create(<q-args>)

function Cf_list()
  let l:cmd = "cd cloudformation;bash scripts/list_stacks"
  execute s:env . l:cmd . "'"
endfunction
command! -nargs=0 -complete=command Cflist call Cf_list()

function Cf_delete(stack_name)
  let l:cmd = "cd cloudformation;bash scripts/delete_stack "
  execute s:env . l:cmd . a:stack_name . "'"
endfunction
command! -nargs=+ -complete=command Cfdelete call Cf_delete(<q-args>)

function Cf_update(stack_name)
  let l:cmd = "cd cloudformation;bash scripts/update_stack "
  execute s:env . l:cmd . a:stack_name . "'"
endfunction
command! -nargs=+ -complete=command Cfupdate call Cf_update(<q-args>)
