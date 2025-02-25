{
  # 描述当前 Nix flake 的用途
  description = "Hugo Development Environment";

  # 这里定义了 Nix flake 的输入
  inputs = {
    # 使用最新的 nixpkgs（不稳定版），包含最新的软件包
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # `outputs` 定义了这个 flake 能提供什么功能
  outputs = { self, nixpkgs }: 
    let 
      # 定义支持的系统架构（可以按需修改）
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # 这个函数遍历 `systems` 列表，为每个架构生成一个值
      forEachSystem = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) systems);
    in {
      # `devShells` 定义可用的开发环境
      devShells = forEachSystem (system:
        let 
          # 引入 nixpkgs，指定当前架构
          pkgs = import nixpkgs { inherit system; };
        in {
          # `nix develop` 默认使用的 shell 环境
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.hugo  # Hugo 静态网站生成器
              pkgs.git   # Git 版本控制工具
            ];

            # 可选：进入 shell 时执行的命令
            shellHook = ''
              echo "🎉Welcome to your Hugo development environment!"
              echo "⚙️  Run 'hugo server -D' to start your local server."
            '';
          };
        }
      );
    };
}

