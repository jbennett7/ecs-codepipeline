let s:env = "!ssh ubuntu@terraform -C 'cd ecs-codepipeline;"

function Update()
  let l:cmd = "git pull"
  execute s:env . l:cmd . "'"
endfunction
command! -nargs=0 -complete=command Update call Update()

function UpdateAll(msg)
  if empty(a:msg)
    let l:msg = "changes"
  else
    let l:msg = a:msg
  endif
  execute "!git add " . expand("%")
  call GitCommit(l:msg)
  execute "!git push origin master"
  call Update()
endfunction
command! -nargs=* -complete=command UpdateAll call UpdateAll(<q-args>)

function Cf_utils()
  let l:cmd = "cd cloudformation;aws cloudformation create-stack"
  let l:cmd = l:cmd . " --stack-name Utilities"
  let l:cmd = l:cmd . " --template-body file://Macros.yml"
  let l:cmd = l:cmd . " --capabilities CAPABILITY_IAM"
  execute s:env . l:cmd . "'"
endfunction
command! -nargs=* -complete=command Utils call Cf_utils()

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
