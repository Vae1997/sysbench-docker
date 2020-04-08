# sysbench-docker
用于sysbench测试的Dockerfile文件

[sysbench.sh](https://github.com/Vae1997/sysbench-docker/blob/master/sysbench.sh)：该脚本针对sysbench的fileio进行测试，固定了相关参数，执行时传入MODE和COUNT参数
- MODE：对应fileio的--file-test-mode参数，指定文件测试模式
- COUNT：指定执行测试的次数

脚本通过获取原始命令的输出，并提取有效数据，简单对测试结果进行平均处理。
