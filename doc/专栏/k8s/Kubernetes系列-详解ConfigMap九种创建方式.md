 

> 内容简介：上一节主要学习使用 Kubernetes ConfigMaps 和 Secrets 设置环境变量，本节我们将学习，创建ConfigMap 的10种方式。

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/310727cd6945483bb63090f4017c2b34.png)

* * *

### ConfigMap 九种创建方式

*   [什么是ConfigMap]
*   [创建 ConfigMap]
    *   [1.2、基于目录创建 ConfigMap]
    *   [1.3、基于文件创建 ConfigMap]
    *   [1.4、定义从文件创建 ConfigMap 时要使用的键]
    *   [1.5、根据字面值创建 ConfigMap]
    *   [1.6、基于生成器创建 ConfigMap]
    *   [1.7、基于文件生成 ConfigMap]
    *   [1.8、定义从文件生成 ConfigMap 时要使用的键]
    *   [1.9、基于字面值生成 ConfigMap]
*   [总结]

* * *

什么是ConfigMap
==========================================================================

很多应用在其初始化或运行期间要依赖一些配置信息。大多数时候， 存在要调整配置参数所设置的数值的需求。 ConfigMap 是 Kubernetes 用来向应用 Pod 中注入配置数据的方法。

ConfigMap 允许你将配置文件与镜像文件分离，以使容器化的应用程序具有可移植性。 本节内容将学习，如何创建 ConfigMap 以及配置 Pod 使用存储在 ConfigMap 中的数据。

* * *

创建 ConfigMap
==========================================================================

我们可以使用 `kubectl create configmap` 或者在 `kustomization.yaml` 中的 ConfigMap 生成器来创建 ConfigMap。kubectl 从 1.14 版本开始支持 kustomization.yaml。

1.1、使用 kubectl create configmap 创建 ConfigMap
----------------------------------------------------------------------------------------------------------

使用 `kubectl create configmap` 命令基于**目录、 文件**或者**字面值**来创建 ConfigMap：

> $ kubectl create configmap <映射名称> <数据源>

<`映射名称`\> 是为 ConfigMap 指定的名称，<`数据源`\> 是要从中提取数据的目录、 文件或者字面值。ConfigMap 对象的名称必须是合法的 **DNS** 子域名.

在基于文件来创建 ConfigMap 时，<`数据源`\> 中的键名默认取自文件的基本名， 而对应的值则默认为文件的内容。

也可以使用`kubectl describe` 或者 `kubectl get` 获取有关 ConfigMap 的信息。

1.2、基于目录创建 ConfigMap
----------------------------------------------------------------------------------

使用 `kubectl create configmap` 基于同一目录中的多个文件创建 ConfigMap。 基于目录来创建 ConfigMap 时，kubectl 识别目录下基本名可以作为合法键名的文件， 并将这些文件打包到新的 ConfigMap 中。普通文件之外的所有目录项都会被忽略 （例如：子目录、符号链接、设备、管道等等）。

1.  创建本地目录

> $ mkdir -p configure-pod-container/configmap/

2.  将示例文件下载到 `configure-pod-container/configmap/` 目录

> $ wget https://kubernetes.io/examples/configmap/game.properties -O configure-pod-container/configmap/game.properties  
> $ wget https://kubernetes.io/examples/configmap/ui.properties -O configure-pod-container/configmap/ui.properties  
> ![在这里插入图片描述](https://img-blog.csdnimg.cn/84ec14a3d47e4377be4036174f7afea8.png)

3.  创建 configmap

> $ kubectl create configmap game-config --from-file=configure-pod-container/configmap/

以上命令将 `configure-pod-container/configmap` 目录下的所有文件，也就是 `game.properties` 和 `ui.properties` 打包到 **game-config ConfigMap** 中。

你可以使用下面的命令显示 ConfigMap 的详细信息：

> $ kubectl describe configmaps game-config

命令执行结果如下：

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/8c020a66451b4167aa27e3cf42c399c9.png)

**configure-pod-container/configmap/** 目录中的 `game.properties` 和 `ui.properties` 文件出现在 ConfigMap 的 data 部分。

> $ kubectl get configmaps game-config -o yaml

执行结果如下:

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/d3ffda7a7a50492c9b33c361a6d89656.png)

1.3、基于文件创建 ConfigMap
----------------------------------------------------------------------------------

使用 `kubectl create configmap` 基于单个文件或多个文件创建 ConfigMap。

执行如下命令：

> $ kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties

再次执行如下命令：

> $ kubectl describe configmaps game-config-2

执行结果如下:

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/d0fab299ace54d1d9bad7c264d7e4de4.png)

也可以多次使用 `--from-file` 参数，从多个数据源创建 ConfigMap，如下：

> $ kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties --from-file=configure-pod-container/configmap/ui.properties

现在可以使用以下命令显示 **game-config-2 ConfigMap** 的详细信息：

> $ kubectl describe configmaps game-config-2

执行结果如下：

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/18c636c28509495dbb89fca86e2b1286.png)

当 kubectl 基于非 ASCII 或 UTF-8 的输入创建 ConfigMap 时， 该工具将这些输入放入 ConfigMap 的 binaryData 字段，而不是 data 中。 同一个 ConfigMap 中可同时包含文本数据和二进制数据源。 如果你想查看 ConfigMap 中的 binaryData 键（及其值）， 可以运行命令 `kubectl get configmap -o jsonpath='{.binaryData}' <name>`。

使用 `--from-env-file` 选项从环境文件创建 ConfigMap

Env 文件包含环境变量列表。其中适用以下语法规则:

*   Env 文件中的每一行必须为 VAR=VAL 格式。
*   以＃开头的行（即注释）将被忽略。
*   空行将被忽略。
*   引号不会被特殊处理（即它们将成为 ConfigMap 值的一部分）。

将示例文件下载到 configure-pod-container/configmap/ 目录：

> $ wget https://kubernetes.io/examples/configmap/game-env-file.properties -O configure-pod-container/configmap/game-env-file.properties  
> $ wget https://kubernetes.io/examples/configmap/ui-env-file.properties -O configure-pod-container/configmap/ui-env-file.properties

Env 文件 `game-env-file.properties` 如下：

```shell
cat configure-pod-container/configmap/game-env-file.properties

enemies=aliens
lives=3
allowed="true"

$ kubectl create configmap game-config-env-file \
       --from-env-file=configure-pod-container/configmap/game-env-file.properties


```

现在我们获得了一个名为 **game-config-env-file** 的ConfigMap，执行下面命令：

> $ kubectl get configmap game-config-env-file -o yaml

获得当前ConfigMap 的详情：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2022-07-11T18:36:28Z
  name: game-config-env-file
  namespace: default
  resourceVersion: "809965"
  selfLink: /api/v1/namespaces/default/configmaps/game-config-env-file
  uid: d9d1ca5b-eb34-11e7-887b-42010a8002b8
data:
  allowed: '"true"'
  enemies: aliens
  lives: "3"

```

从 Kubernetes 1.23 版本开始，kubectl 支持多次指定 `--from-env-file` 参数来从多个数据源创建 ConfigMap。

> $ kubectl create configmap config-multi-env-files  
> –from-env-file=configure-pod-container/configmap/game-env-file.properties  
> –from-env-file=configure-pod-container/configmap/ui-env-file.properties

现在我们获得了一个名为 **config-multi-env-files** 的ConfigMap，执行下面命令：

> $ kubectl get configmap config-multi-env-files -o yaml

获得当前ConfigMap 的详情：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2022-07-11T18:38:34Z
  name: config-multi-env-files
  namespace: default
  resourceVersion: "810136"
  uid: 252c4572-eb35-11e7-887b-42010a8002b8
data:
  allowed: '"true"'
  color: purple
  enemies: aliens
  how: fairlyNice
  lives: "3"
  textmode: "true"

```

1.4、定义从文件创建 ConfigMap 时要使用的键
------------------------------------------------------------------------------------------

在使用 `--from-file` 参数时，你可以定义在 ConfigMap 的 data 部分出现键名， 而不是按默认行为使用文件名：

> $ kubectl create configmap game-config-3 --from-file=<我的键名>=<文件路径>

<`我的键名`\> 是你要在 ConfigMap 中使用的键名，<`文件路径`\> 是你想要键所表示的数据源文件的位置。

> $ kubectl create configmap game-config-3 --from-file=game-special-key=configure-pod-container/configmap/game.properties

现在我们获得了一个名为 **configmaps game-config-3** 的ConfigMap，执行下面命令：

> $ kubectl get configmaps game-config-3 -o yaml

获得当前ConfigMap 的详情：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2022-07-11T18:54:22Z
  name: game-config-3
  namespace: default
  resourceVersion: "530"
  uid: 05f8da22-d671-11e5-8cd0-68f728db1985
data:
  game-special-key: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30    

```

1.5、根据字面值创建 ConfigMap
-----------------------------------------------------------------------------------

可以将 `kubectl create configmap` 与 `--from-literal` 参数一起使用， 通过命令行定义文字值：

> $ kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm

可以传入多个键值对。命令行中提供的每对键值在 ConfigMap 的 data 部分中均表示为单独的条目。

> $ kubectl get configmaps special-config -o yaml

输出结果如下：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2022-07-11T19:14:38Z
  name: special-config
  namespace: default
  resourceVersion: "651"
  uid: dadce046-d673-11e5-8cd0-68f728db1985
data:
  special.how: very
  special.type: charm
  

```

1.6、基于生成器创建 ConfigMap
-----------------------------------------------------------------------------------

自 1.14 开始，**kubectl** 开始支持 **kustomization.yaml**。 你还可以基于生成器（Generators）创建 ConfigMap，然后将其应用于 API 服务器上创建对象。 生成器应在目录内的 **kustomization.yaml** 中指定。

1.7、基于文件生成 ConfigMap
----------------------------------------------------------------------------------

要基于 `configure-pod-container/configmap/game.properties` 文件生成一个 ConfigMap：

创建包含 ConfigMapGenerator 的 kustomization.yaml 文件

```shell
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-4
  files:
  - configure-pod-container/configmap/game.properties
EOF

```

应用（Apply）kustomization 目录创建 ConfigMap 对象：

```shell
$ kubectl apply -k .
configmap/game-config-4-m9dm2f92bt created

```

检查 ConfigMap 被创建命令：

> $ kubectl get configmap

检查结果如下：

![在这里插入图片描述](img/%E3%80%90Kubernetes%20%E7%B3%BB%E5%88%97%E3%80%91%E8%AF%A6%E8%A7%A3%20ConfigMap%20%E4%B9%9D%E7%A7%8D%E5%88%9B%E5%BB%BA%E6%96%B9%E5%BC%8F/319de99b043c4d5c8ed4354203b5e395.png)

生成的 ConfigMap 名称具有通过对内容进行散列而附加的后缀， 这样可以确保每次修改内容时都会生成新的 ConfigMap。

1.8、定义从文件生成 ConfigMap 时要使用的键
------------------------------------------------------------------------------------------

在 ConfigMap 生成器中，你可以定义一个非文件名的键名。 例如，从 `configure-pod-container/configmap/game.properties` 文件生成 ConfigMap， 但使用 game-special-key 作为键名：

```shell
# 创建包含 ConfigMapGenerator 的 kustomization.yaml 文件
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-5
  files:
  - game-special-key=configure-pod-container/configmap/game.properties
EOF

```

应用 Kustomization 目录创建 ConfigMap 对象。

```shell
$ kubectl apply -k .
configmap/game-config-5-m67dt67794 created

```

1.9、基于字面值生成 ConfigMap
-----------------------------------------------------------------------------------

要基于字符串 `special.type=charm` 和 `special.how=very` 生成 ConfigMap， 可以在 kustomization.yaml 中配置 ConfigMap 生成器：

```shell
# 创建带有 ConfigMapGenerator 的 kustomization.yaml 文件
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: special-config-2
  literals:
  - special.how=very
  - special.type=charm
EOF

```

应用 Kustomization 目录创建 ConfigMap 对象。

```shell
 $ kubectl apply -k .
configmap/special-config-2-c92b5mmcf2 created

```

总结
================================================================

本文主要介绍了创建ConfigMap 的九种方式，学完本节内容，我想你对ConfigMap 也有了一定的了解，下一节我们将一起学习 **如何使用 ConfigMap 数据定义容器环境变量**

 
