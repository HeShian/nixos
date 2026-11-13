# 应用集合统一选择，安装与接线按应用关注点维护

两台 Host 通过 `desktop` Role 使用同一套应用，没有逐应用独立选择的需求。以 `desktop-applications` Aspect 统一承担普通应用的安装、默认关联与接线，内部按应用关注点组织，替代按 packages / mimeapps / app-integrations 拆开的三个 Aspect；出现实际独立消费需求时再拆分。

现有默认关联随对应应用关注点维护，Dux Calendar 与便签的关联归入 `dux`，与 Dux Files 的关联共同由 Dux 关注点维护。安装其他应用不自动改变默认选择；各自维护关联的 Aspect 同时启用 MIME 管理。VS Code 的可写主题扩展安装属于应用接线，Qt / GTK 主题依赖属于外观。

取舍是默认应用选择分布在各自关注点，换来更换应用时能就近检查安装与关联，避免配套知识泄漏到 Role。此次沿用现有软件集合、默认选择、Dotfile 与运行时生成文件的写入方式。
