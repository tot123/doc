
# linx磁盘占用排查

### 概要
```shell
# 查询磁盘整体占用情况
[root@ts /]# df -h
# 查询 根目录 按照占用大小排序
[root@ts /]# du  -s /* | sort -nr
# 查询指定目录 /var 文件占用的大小 
[root@ts /]# du -h --max-depth=1 /var
```


### 具体操作详情
```shell
[root@ts /]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        3.7G     0  3.7G   0% /dev
tmpfs           3.7G     0  3.7G   0% /dev/shm
tmpfs           3.7G  916K  3.7G   1% /run
tmpfs           3.7G     0  3.7G   0% /sys/fs/cgroup
/dev/vda1        50G   45G  2.2G  96% /
tmpfs           756M     0  756M   0% /run/user/0
overlay          50G   45G  2.2G  96% /var/lib/docker/overlay2/fa9bf1ab280d54c5c9b9dc8cd8d656ca567281bdc5629de36ab6e1f460b0e4a8/merged
overlay          50G   45G  2.2G  96% /var/lib/docker/overlay2/895bd23b887a449b6b7bb414dedb521a968410e6c28b064bcd020a7a6a6f4e92/merged
overlay          50G   45G  2.2G  96% /var/lib/docker/overlay2/8750d1479f5357eeba968f464f47c9d6e5c1a9d7a94bbfab05946eecd4c478d9/merged
overlay          50G   45G  2.2G  96% /var/lib/docker/overlay2/25ee2a9766caffd10929dfdce42ad8bf5f1823e56ecc422328862f44fef1d96e/merged
[root@ts /]# du  -s /* | sort -nr
du: cannot access ‘/proc/15954/task/15954/fd/4’: No such file or directory
du: cannot access ‘/proc/15954/task/15954/fdinfo/4’: No such file or directory
du: cannot access ‘/proc/15954/fd/4’: No such file or directory
du: cannot access ‘/proc/15954/fdinfo/4’: No such file or directory
25763520	/var
5270856	/root
5199600	/usr
4653020	/docker
2895764	/spider
2240664	/mydata
1772648	/home
515156	/mydate
310284	/opt
202700	/boot
62672	/logs
45556	/etc
40264	/data
916	/run
68	/tmp
16	/lost+found
16	/huyanli
12	/docekr
4	/srv
4	/repository
4	/mnt
4	/media
4	/lizexu
0	/sys
0	/sbin
0	/proc
0	/lib64
0	/lib
0	/dev
0	/bin
[root@ts /]# du -h --max-depth=1 /var
4.0K	/var/gopher
8.0K	/var/empty
24K	/var/db
4.0K	/var/nis
4.0K	/var/local
4.0K	/var/adm
16K	/var/tmp
4.0K	/var/yp
108K	/var/spool
4.0K	/var/opt
4.0K	/var/preserve
266M	/var/cache
12K	/var/kerberos
4.4G	/var/log
4.0K	/var/crash
4.0K	/var/games
20G	/var/lib
25G	/var

```