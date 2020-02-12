#!/usr/bin/env bash
#----------------------------------#
# 功能说明: 项目启动脚本, sh coding-config-server.sh [start|stop|restart|status]
# 作者    : lwk
# 日期    : 2020-2-12 17:45:51
#----------------------------------#

begin_time=`date +"%s"`
echo "script begin_time: " $(date +"%Y-%m-%d %H:%M:%S")

echo "=========================================="
echo "启动脚本开始执行..."
echo "------------------------------------------"

# 系统日期
sys_date=`date +"%Y%m%d"`
echo "系统日期: "${sys_date}

# 获取运行环境
if [ -z ${ENV_LABEL} ]; then
  echo "ENV_LABEL is not set up..."
  exit 1
fi
RUN_ENV=${ENV_LABEL}
echo "运行环境: "${RUN_ENV}

command=$1
echo "执行命令: "${command}

# 项目目录
HOME_PATH=$(cd `dirname $0`;cd ../; pwd);
echo "项目目录: "${HOME_PATH}

# 项目名称
app_name=coding-config-server
# 获取jar文件
for jar in "${HOME_PATH}"/*.jar
do
  app_jar=${jar}
done
echo "JAR 文件: "${app_jar}
echo "------------------------------------------"

# 启动服务
start_app(){
    app_pid=`ps -ef|grep $app_jar|grep -v grep|grep -v kill|awk '{print $2}'`
    if [ ${app_pid} ]; then
        echo "${app_jar} is running, pid = ${app_pid}"
    else
        if [ -e ${app_jar} ]; then
            # DUMP快照
            dump_path=${HOME_PATH}/dump/
            echo "DUMP快照: "${dump_path}
            # 日志文件夹不存在，则创建
            if [ ! -d ${dump_path} ]; then
                mkdir -p ${dump_path}
            fi

            nohup java -jar ${app_jar} -server -Xms512m -Xmx512m -Xmn256m -Xss2m \
                -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${dump_path}    \
                --spring.profiles.active=${RUN_ENV}                              \
                --jasypt.encryptor.password=${ENC_KEY}                           \
                >/dev/null 2>&1 &

            if [ $? -eq 0 ]; then
              echo "${app_jar} start sucess~"
            else
              echo "${app_jar} start failed..."
              exit 1
            fi
            
            # 打印运行状态
            status_app
        else
            echo "${app_jar} is not exist..."
        fi
    fi
}

# 停止服务
stop_app(){
    app_pid=`ps -ef|grep $app_jar|grep -v grep|grep -v kill|awk '{print $2}'`
    if [ ${app_pid} ]; then
        echo "${app_jar} is beginning to be killed normally, pid = ${app_pid}"
        kill -15 ${app_pid}
    fi
    sleep 3

    app_pid=`ps -ef|grep $app_jar|grep -v grep|grep -v kill|awk '{print $2}'`
    if [ ${app_pid} ]; then
        echo "${app_jar} is beginning to be killed forcibly, pid = ${app_pid}"
        kill -9 ${app_pid}
        
        sleep 3
        echo "${app_jar} has been killed~"
    else
        echo "${app_jar} is not running~"
    fi
}

# 查看服务状态
status_app(){
    app_pid=`ps -ef|grep $app_jar|grep -v grep|grep -v kill|awk '{print $2}'`
    if [ ${app_pid} ]; then
        echo "${app_jar} is running, pid = ${app_pid}"
    else
        echo "${app_jar} is not running~"
    fi
}

# 重启服务
restart_app(){
  stop_app
  start_app
}

case "${command}" in 
  "start") 
    start_app 
    ;; 
  "stop") 
    stop_app 
    ;; 
  "status") 
    status_app 
    ;; 
   "restart") 
    restart_app 
    ;; 
  *)
    echo "NOTE: sh coding-config-server.sh [start|stop|status|restart]"
    ;;
esac

echo "------------------------------------------"
echo "启动脚本执行结束..."
echo "=========================================="

end_time=`date +"%s"`
echo "script end_time: " $(date +"%Y-%m-%d %H:%M:%S")
echo "script exec_cost: " $((end_time - begin_time))