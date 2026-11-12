# modules/ 扁平化：一个文件一个 aspect，文件名就是 aspect 名

按 Den 的 `templates/default` 形态组织：所有 aspect 文件直接放在 `modules/` 下，文件名与它定义的 `den.aspects.<name>` 完全一致；`dendritic.nix` 只做 Den 的 flake 接入，`hosts.nix` 只放 `den.hosts` 声明，`defaults.nix` 只放 `den.default` / `den.schema`，host 与 user 的 aspect 各自放在 `<host>.nix` / `<user>.nix`。

取代 ADR-0001 中「保留 `modules/aspects/{desktop,system,network}` 分组」的部分。import-tree 是递归的，分组只影响人找文件，却让「这个 aspect 在哪个文件」需要多推断一层；扁平化后 `ls modules/` 与 `grep -r den.aspects` 可以直接对上名字。文件名的命名规则是「文件名 = aspect 名」（如 `desktop-packages.nix` 定义 `den.aspects.desktop-packages`），这样新增 aspect 不需要决定放在哪个子目录。

非 aspect 的辅助代码仍放 `modules/_lib/`——import-tree 的默认过滤会跳过含 `/_` 的路径，不会被当成模块加载。
