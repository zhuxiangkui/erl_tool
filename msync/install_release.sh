function get_repo_host {
    case `hostname` in
        sdb-ali-hangzhou-*)
            echo -n sdb-ali-hangzhou-log
            ;;
        *)
            echo -n sdb-ali-hangzhou-log
            ;;
    esac
}


VSN=$1
SNAME=$2

REPO_HOST=`get_repo_host`
scp $REPO_HOST:/data/msyncupdatepackage/msync_${VSN}.tar.gz /data/apps/opt/msync/
./erl_expect -sname $2 -setcookie `cat $HOME/.erlang.cookie` msync/install_release.erl $VSN

