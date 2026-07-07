#!/bin/bash

set -e

#
# get-mirror.sh - 更新离线安装包
#
# 选项:
#   --force   强制更新 costrict-static.tar 内容（即使本地已存在）
#

BASE_URL="https://zgsm.sangfor.com"

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "从 $BASE_URL 拉取静态安装包"
    echo ""
    echo "选项:"
    echo "  --force   强制更新 costrict-static.tar（即使本地已存在）"
    echo "  --help, -h        显示此帮助信息"
    echo ""
    echo "执行步骤:"
    echo "  获取/更新 costrict-static.tar（从 ${BASE_URL}/costrict-static/costrict-static.tar下载）"
    echo ""
    echo "示例:"
    echo "  $0                 # 本地不存在就获取"
    echo "  $0 --force         # 强制更新"
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

# 下载单个文件
download_file() {
    local file_path="$1"

    # 去除首尾空白
    file_path=$(echo "${file_path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # 去掉 ./ 前缀（防御性处理）
    file_path="${file_path#./}"

    # 安全检查：禁止路径遍历攻击
    if [[ "${file_path}" == *".."* ]]; then
        echo "  [错误] 非法文件路径（包含 ..）: ${file_path}"
        return 1
    fi

    # 安全检查：路径不能为空
    if [[ -z "${file_path}" ]]; then
        echo "  [错误] 文件路径为空"
        return 1
    fi

    # 直接使用 file_path 作为本地存储路径和远程 URL 路径
    local local_path="./${file_path}"
    local remote_url="${BASE_URL}/costrict-static/${file_path}"
    local file_dir

    file_dir=$(dirname "${local_path}")

    # 检查是否需要下载
    local need_download=false
    if [ "$FORCE_UPDATE" = true ]; then
        need_download=true
    elif [ ! -f "${local_path}" ]; then
        need_download=true
    else
        echo "  [跳过] ${file_path} (本地已存在)"
        return 0
    fi

    # 创建目标目录
    mkdir -p "${file_dir}"

    echo "  [下载] ${file_path} <- ${remote_url}"
    if command -v curl &> /dev/null; then
        curl -fSL -o "${local_path}" "${remote_url}"
    elif command -v wget &> /dev/null; then
        wget -q -O "${local_path}" "${remote_url}"
    else
        echo "错误: 未找到 curl 或 wget，无法下载文件。"
        exit 1
    fi
}

echo "----------------------------------------------------------------"
echo " 获取/更新 costrict-static.tar ..."
echo "----------------------------------------------------------------"

download_file "./costrict-static.tar"

echo ""
echo "----------------------------------------------------------------"
echo "costrict-static.tar更新完成"
echo "----------------------------------------------------------------"
