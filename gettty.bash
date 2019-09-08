# declare global variables & initialize
podsArray=()       # necessary
containersArray=() # necessary
defaultShell="bash"
function_name="gettty"

show_dialog() {
  choices=("$@")
  choicesCount=${#choices[@]}
  choice=$(seq ${choicesCount}|xargs|sed "s/ /'|'/g")
  local selected_items_array_index=0
  select opt in "${choices[@]}"
  do
    if [[  $REPLY -le ${choicesCount} && $REPLY -gt 0 ]] ; then
      #printf "${green}You selected $REPLY => $opt${reset}\n"
      selected_items_array_index=$(( REPLY - 1 ))
      break
    #else
    #  printf "${yellow}What's that?${reset}" >&2
    fi
  done
  printf $selected_items_array_index
}

populateContainersArray() {
  local podName=$1
  if [[ "${podName}" ]] ; then
    IFS=' ' read -r -a containersArray <<< $(kubectl get pods ${podName} -o jsonpath='{.spec.containers[*].name}')
  else
    printf "variable #podName: ${podName}# is empty\n"
  fi
}

checkKubeMasterConnection() {
  kubectl get pods > /dev/null
  if [[ "$?" == "0" ]] ; then
    #printf "Connection to Kubernetes Master is success!"
    printf  0
  else
    #echo "Did not get good response from kubectl call. Is your connection to Kubectl works?"
    printf 1
  fi
}

gettty() {
  local selected_pods_array_index=0
  local selected_containers_array_index=0
  if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "?" ]] ; then
    printf "\
      \n${reset}${uline}Description${reset}: Get tty of a container from all the pods currently running \
      \n${reset}${uline}Usage${reset}      : ${yellow}${function_name} <podName> < [shell | command to run]>  ; shellName is optional, default: bash \
      \n${reset}${uline}Examples${reset}   : ${green}\
      \n  ${function_name}             ; this assumes $defaultShell as default shell, it's configurable \
      \n  ${function_name} sh          ; You will be get into the shell you specified \
      \n  ${function_name} ls -l       ; Command will be executed directly \
      \n  ${function_name} "tail log/receivingapp.log" ; tail log directly \
      \n${reset}"
    return 0
  fi
  if [[ $(checkKubeMasterConnection) == "1" ]] ; then printf "No connection to K8s master, exiting...\n"; return 1; fi  
  if [ "$1" == "sh" -o "$1" == "bash" -o "$1" == "zsh" -o "$1" == "tcsh" -o -z "$1" ] ; then
    tty_options=" -it "
    shell_options=""
  else
    tty_options=""
    shell_options=" -- "
  fi
  shell=${1-bash}
  IFS=' ' read -r -a podsArray <<< $(kubectl get pods --field-selector=status.phase=Running -o=name | sed 's#^pod/##g' | tr '\n', ' ')
  if [[ ${#podsArray[@]} > 1 ]] ; then
    printf "\e[33mThere are multiple pods, please choose one...\n\e[0m"
    PS3='Please Select a POD: '
    selected_pods_array_index=$(show_dialog "${podsArray[@]}")
  fi
  printf "${yellow}Selected Pod: ${podsArray[${selected_pods_array_index}]} ${dim}[auto selected when podCount <=1]${reset}\n"
  populateContainersArray "${podsArray[${selected_pods_array_index}]}"
  if [[ ${#containersArray[@]} > 1 ]] ; then
    printf "\e[33mThere are multiple containers, please choose one...\n\e[0m"
    PS3='Please Select a container: '
    selected_containers_array_index=$(show_dialog "${containersArray[@]}")
    cmd="kubectl exec ${tty_options} ${podsArray[${selected_pods_array_index}]} -c ${containersArray[${selected_containers_array_index}]} ${shell_options} $shell"
  else
    cmd="kubectl exec ${tty_options} ${podsArray[${selected_pods_array_index}]} ${shell_options} $shell"
  fi
  printf "${green}  command: $cmd ${reset}\n"
  $cmd
}