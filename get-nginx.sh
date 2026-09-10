#!/bin/bash

set -e

#
# get-nginx.sh - 拉取并保存 nginx 镜像为离线 tar 包
#
# 选项:
#   --force   强制重新拉取并保存（即使本地已存在 nginx-1.31.1.tar）
#

IMAGE="nginx:1.31.1"
IMAGE_TAR="nginx-1.31.1.tar"

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "使用 docker 拉取 ${IMAGE} 并保存为 ${IMAGE_TAR}"
    echo ""
    echo "选项:"
    echo "  --force           强制重新拉取并保存（即使本地已存在 ${IMAGE_TAR}）"
    echo "  --help, -h        显示此帮助信息"
    echo ""
    echo "执行步骤:"
    echo "  docker pull ${IMAGE}"
    echo "  docker save -o ${IMAGE_TAR} ${IMAGE}"
    echo ""
    echo "示例:"
    echo "  $0                 # 本地不存在就拉取并保存"
    echo "  $0 --force         # 强制重新拉取并保存"
    echo ""
}

# 解析参数
FORCE_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查 docker 是否可用
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到 docker，请先安装 Docker。"
    exit 1
fi

echo "----------------------------------------------------------------"
echo " 拉取并保存 ${IMAGE} ..."
echo "----------------------------------------------------------------"

# 检查是否需要处理
if [ "$FORCE_UPDATE" = false ] && [ -f "${IMAGE_TAR}" ]; then
    echo "  [跳过] ${IMAGE_TAR} (本地已存在，使用 --force 可强制更新)"
else
    echo "  [拉取] ${IMAGE}"
    docker pull "${IMAGE}"

    echo "  [保存] ${IMAGE} -> ${IMAGE_TAR}"
    docker save -o "${IMAGE_TAR}" "${IMAGE}"
fi

echo ""
echo "----------------------------------------------------------------"
echo "${IMAGE_TAR} 生成完成"
echo "----------------------------------------------------------------"
