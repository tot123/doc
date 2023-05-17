
1. Markdown All in One  
1. markdown 文件,包含多种md编辑插件

    第一个插件，是一个组合包，一股脑把最常用的Markdown优化都给你装好；

2. Markdown Preview Github Styling  

    第二个插件，则是Github使用的Markdown渲染样式，不是特别华丽，很朴素，很简洁的样式，因为很多人用Markdown都是为了使用Github Pages，所以这个样式特别受欢迎。使用这个样式，在本地就能预览Markdown文件最终在Github Pages中显示的效果。

3. Paste Image

    安装好这个插件后，截好图后，默认按下Ctrl+Alt+V就能把截图添加到md文档里面了。
    图片会默认保存在当前编辑文档的所在目录，当然你也可以自定义路径，如下

    文件——首选项——设置——搜索“Paste Image”

    修改 Paste Image: Path 可以设置图片的保存路径，我这里设置的是${currentFileDir}/img，即在当前文档目录下再创建一个名为img的文件夹，所有的截图存在这个img文件夹下。如果img文件夹不存在会自动创建的。
    修改 Paste Image: Name Prefix 给图片添加一个前缀，主要是个人习惯了，方便以后整理。
    
    "MarkdownPaste.namePrefix": "mk-"
    "MarkdownPaste.path": "${fileDirname}/${fileBasenameNoExtension}"
    出现问题: You need to install xclip command first.
    
    ```
    # 查看linux版本：
    lsb_release -a
    # 安装 xclip
    sudo apt-get update -y
    sudo apt-get install -y xclip
    ```
    [markdown-paste-image](https://github.com/telesoho/vscode-markdown-paste-image)
4. 
5. 