# RG35XX FinUI 全程安装与汉化指南

这份指南汇总了从格式化 SD 卡到完整汉化及批量同步游戏的所有步骤。

## 准备工作

> [!IMPORTANT]
> 建议使用 **64GB** 的品牌 microSD 卡。

1. **软件**: `35XX-64GB230309EN.IMG` (官方固件镜像)。
   > [!TIP]
   > 请前往本仓库的 [Releases](https://github.com/leomsn/RG35XX-MyFinUI-CN/releases) 页面下载该大文件镜像。这样可以避免占用 LFS 额度，下载也更快速。
2. **系统**: 工作目录下的 `MinUI.zip` (已预置中文字体) 和 `dmenu.bin`。
3. **字体**: `BPreplayBold-unhinted.otf` (工作目录中)。
4. **备份**: 电脑上的 ROM 备份文件夹（默认指向 `/Users/leo/_Backup/RG35XX/Roms`）。

## 第一阶段：系统安装

1. **刷入固件**:
   ```bash
   # 识别磁盘号后（如 /dev/diskN）
   sudo dd bs=1m if=./35XX-64GB230309EN.IMG of=/dev/rdisk13 status=progress
   ```
2. **扩容至 64GB**:
   - 修复分区表：`diskutil repairDisk /dev/disk13` (遇提示按 `y`)。
   - 删除小分区并重建：
     ```bash
     diskutil eraseVolume "Free Space" "" /dev/disk13s4
     diskutil addPartition disk13 FAT32 ROMS 0
     ```
3. **部署系统文件**:
   - 将 `dmenu.bin` 拷入 `misc` 分区。
   - 将 `MinUI.zip` 及 `Bios`、`Emus`、`Roms`、`Saves`、`Tools` 拷入 `ROMS` 分区。

## 第二阶段：中文汉化 (本地集成)

我已经将字体自动注入了工作目录下的 `MinUI.zip`。后续安装该包时，系统将直接显示中文。

**手动更新现有的卡 (如果需要):**
- 替换 `/Volumes/ROMS/.system/res/BPreplayBold-unhinted.otf` 为 17.6MB 的版本即可。

## 第三阶段：游戏批量同步 (使用脚本)

为了提高复用性，我提供了一个 `sync_roms.sh` 脚本，支持自定义源目录。

### 1. 脚本特色
- **参数化支持**: 可通过参数指定不同的源目录，更具人性化。
- **自动映射**: 自动对应备份目录与 MinUI 的中文/长文件名目录。
- **智能过滤**: 自动跳过已存在的文件，仅同步新游戏。
- **一键清理**: 同步完成后自动执行 macOS 系统文件清理（`.DS_Store` 等）。

### 2. 使用方法
### 1. 脚本特色
- **参数化支持**: 可通过参数指定不同的源目录，更具人性化。
- **自动映射**: 自动对应备份目录与 MinUI 的中文/长文件名目录。
- **智能过滤**: 自动跳过已存在的文件，仅同步新游戏。
- **一键清理**: 同步完成后自动执行 macOS 系统文件清理（`.DS_Store` 等）。

### 2. 使用方法
1. 首先进入项目根目录。
2. 赋予执行权限（仅需一次）：
   ```bash
   chmod +x sync_roms.sh
   ```
3. **执行同步**：
   - **使用默认路径** (脚本内预设)：
     ```bash
     ./sync_roms.sh
     ```
   - **手动指定路径** (推荐，例如从外接硬盘快速导入)：
     ```bash
     ./sync_roms.sh /path/to/your/Roms
     ```

---

## 第四阶段：维护与清理

建议每次手动复制游戏后运行一次清理命令：
```bash
dot_clean -m /Volumes/ROMS
find /Volumes/ROMS -name "._*" -delete
```

---
*上次更新：2026-02-02 (加入参数化同步指令)*
