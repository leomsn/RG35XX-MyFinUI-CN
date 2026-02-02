#!/bin/bash

# ==============================================================================
# RG35XX ROM 同步脚本 (参数化版本)
# ==============================================================================

# --- 自动挂载点检测 ---
if [ -d "/Volumes/ROMS/Roms" ]; then
    TARGET_ROOT="/Volumes/ROMS/Roms"
elif [ -d "/Volumes/ROMS 1/Roms" ]; then
    TARGET_ROOT="/Volumes/ROMS 1/Roms"
else
    echo "❌ 错误: 找不到 SD 卡 ROMS 分区挂载点！"
    exit 1
fi

# --- 参数处理 ---
# 默认源目录路径 (可在此修改或通过参数传入)
DEFAULT_SOURCE="./Roms"
SOURCE_ROOT="${1:-$DEFAULT_SOURCE}"

if [ ! -d "$SOURCE_ROOT" ]; then
    echo "❌ 错误: 找不到源目录 [$SOURCE_ROOT]"
    echo "用法: $0 [源目录路径]"
    echo "示例: $0 /Volumes/ExternalDrive/MyRoms"
    exit 1
fi

echo "📂 源目录: $SOURCE_ROOT"
echo "💾 目标磁盘: $TARGET_ROOT"
echo "------------------------------------------------"

# 同步函数
sync_dir() {
    local src_name="$1"
    local dst_name="$2"
    local src_path="$SOURCE_ROOT/$src_name"
    local dst_path="$TARGET_ROOT/$dst_name"

    [ ! -d "$src_path" ] && return

    echo "▶️ 正在处理: [$src_name] -> [$dst_name]"
    mkdir -p "$dst_path"

    local total=$(find "$src_path" -type f ! -name ".DS_Store" | wc -l | xargs)
    [ "$total" -eq 0 ] && echo "  ℹ️ 跳过: 空目录" && return

    local count=0
    local copied=0
    local skipped=0

    while IFS= read -r src_file; do
        count=$((count + 1))
        local rel_path="${src_file#$src_path/}"
        local dst_file="$dst_path/$rel_path"
        mkdir -p "$(dirname "$dst_file")"

        if [ -f "$dst_file" ]; then
            skipped=$((skipped + 1))
        else
            cp -p "$src_file" "$dst_file"
            copied=$((copied + 1))
        fi

        if (( count % 10 == 0 )) || [ "$count" -eq "$total" ]; then
            printf "\r  进度: %d/%d (新复制: %d, 已跳过: %d)   " "$count" "$total" "$copied" "$skipped"
        fi
    done < <(find "$src_path" -type f ! -name ".DS_Store")
    
    echo -e "\n  ✅ 完成"
}

# --- 执行映射列表 ---
sync_dir "FC"    "Nintendo Entertainment System (FC)"
sync_dir "SFC"   "Super Nintendo Entertainment System (SFC)"
sync_dir "MD"    "Sega Genesis (MD)"
sync_dir "GBA"   "Game Boy Advance (GBA)"
sync_dir "GB"    "Game Boy (GB)"
sync_dir "GBC"   "Game Boy Color (GBC)"
sync_dir "GG"    "Sega Game Gear (GG)"
sync_dir "MS"    "Sega Master System (SMS)"
sync_dir "PS"    "Sony PlayStation (PS)"
sync_dir "PCE"   "TurboGrafx-16 (PCE)"
sync_dir "ARCADE" "Arcade (MAME)"
sync_dir "FBNEO" "FinalBurnNeo (FBN)"
sync_dir "NGP"   "Neo Geo Pocket Color (NGPC)"
sync_dir "SGB"   "Super Game Boy (SGB)"
sync_dir "VB"    "Virtual Boy (VB)"
sync_dir "POKE"  "Pokémon mini (PKM)"
sync_dir "PICO"  "Pico-8 (P8)"
sync_dir "AMIGA" "Amiga (PUAE)"

echo "------------------------------------------------"
echo "🏁 同步任务结束！"
echo "⚙️ 正在执行 macOS 系统文件清理..."
dot_clean -m "$(dirname "$TARGET_ROOT")"
find "$(dirname "$TARGET_ROOT")" -name "._*" -delete
echo "✨ 全部完成。现在可以安全弹出 SD 卡了。"
