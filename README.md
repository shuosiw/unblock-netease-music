# unblock-netease-music

## 写在前面

虽然 dockerhub 已经有了 nodejs 版本的镜像，不过出于以下个人原因，重新制作了一个 go 版本的镜像：

* 个人更喜欢轻量化 golang 版本，不需要 nodejs 环境，基于 alphine 构建后镜像最终大小不超过 10MB
* 为了在 unraid 上能更方便使用，定制了从环境变量获取配置的启动方式，使用起来更友好

关于 unraid 上配置使用，已经提供了对应的安装模板，详见：https://github.com/shuosiw/unraid


## 镜像说明

为了使用方便，对 [cnsilvan/UnblockNeteaseMusic](https://github.com/cnsilvan/UnblockNeteaseMusic) 进行了 docker 封装，提供一个镜像。同时，为了方便使用，提供了定义环境变量的方式来配置并运行 UnblockNeteaseMusic。

为了保证兼容性，固定了 UnblockNeteaseMusic 版本，目前为 [v0.2.9](https://github.com/cnsilvan/UnblockNeteaseMusic/releases/tag/0.2.9) 版本。当然，主要还是因为懒，直接将对应的二进制文件以及证书文件放到本 repo 的目录中。你可以选择将 UnblockNeteaseMusic 目录中的二进制文件以及证书文件替换为你想要的版本。


## 环境变量

以下引用了自 [cnsilvan/UnblockNeteaseMusic - 具体参数说明](https://github.com/cnsilvan/UnblockNeteaseMusic#%E5%85%B7%E4%BD%93%E5%8F%82%E6%95%B0%E8%AF%B4%E6%98%8E) 

```
 ./UnblockNeteaseMusic -h

  -b    force the best music quality
  -c string
        specify server cert,such as : "server.crt" (default "./server.crt")
  -e    enable replace song url
  -k string
        specify server cert key ,such as : "server.key" (default "./server.key")
  -l string
        specify log file ,such as : "/var/log/unblockNeteaseMusic.log"
  -m int
        specify running mode（1:hosts） ,such as : "1" (default 1)
  -o string
        specify server source,such as : "kuwo" (default "kuwo")
  -p int
        specify server port,such as : "80" (default 80)
  -sl int
        specify the number of songs searched on other platforms(the range is 0 to 3) ,such as : "1"
  -sp int
        specify server tls port,such as : "443" (default 443)
  -v    display version info
```

本镜像通过一个脚本，在容器启动时，从环境变量中检测并获取参数，最终拼装成 UnblockNeteaseMusic 的启动参数，对应的参数介绍如下：

| 变量名 | 变量说明 | 对应参数 |
|---|---|---|
| UNM_FORCE_BEST | force the best music quality | `-b` |
| UNM_REPLACE_URL | enable replace song url | `-e` |
| UNM_SERVER_CERT | specify server cert | `-c string` |
| UNM_SERVER_KEY | specify server cert key | `-k string` |
| UNM_LOG_FILE | specify log file | `-l string` |
| UNM_SERVER_SOURCE | specify server source | `-o string` |
| UNM_RUNNING_MODE | specify running mode | `-m int` |
| UNM_SERVER_PORT | specify server port | `-p int` |
| UNM_SERVER_TLS_PORT | specify server tls port | `-sp int` |
| UNM_SEARCH_TIME | specify the number of songs searched | `-sl int` |


## 如何使用

* 如果你是在 unraid 上使用，建议配置我提供的模板仓库，可以实现快速配置部署：https://github.com/shuosiw/unraid
* 如果你是常规 docker 部署，可以在启动镜像的时候设置环境变量进行配置，比如：

    ```
    docker run -d --name='UnblockNeteaseMuisc' -e 'UNM_FORCE_BEST'='on' \
        -e 'UNM_REPLACE_URL'='off' -e 'UNM_SERVER_SOURCE'='kuwo' \
        -e 'UNM_RUNNING_MODE'='1' -e 'UNM_SERVER_PORT'='80' \
        -e 'UNM_SERVER_TLS_PORT'='443' -e 'UNM_SERVER_TLS_PORT'='1' \
        shuosiw/unblock-netease-music
    ```

## 感谢

* [cnsilvan/UnblockNeteaseMusic](https://github.com/cnsilvan/UnblockNeteaseMusic)
