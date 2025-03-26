convert_to_bytes() {
    local size=$1
    local unit=$(echo $size | sed 's/[0-9.]*//g')  # Pobranie jednostki (np. kB, MB, GB)
    local value=$(echo $size | sed 's/[A-Za-z]*//g')  # Pobranie liczby
    # Przeliczanie na bajty w zależności od jednostki
    case "$unit" in
        kB) echo $(echo "$value * 1024" | bc) ;;
        MB) echo $(echo "$value * 1024 * 1024" | bc) ;;
        GB) echo $(echo "$value * 1024 * 1024 * 1024" | bc) ;;
        TB) echo $(echo "$value * 1024 * 1024 * 1024 * 1024" | bc) ;;
        *) echo "$value" ;;  # Zakłada, że już jest w bajtach
    esac
}

# Pobranie informacji o wykorzystaniu miejsca przez Docker
output=$(docker system df)

# Parsowanie rozmiaru wolumenów
volume_size=$(echo "$output" | awk '/Local Volumes/ {print $5}')
volume_size_bytes=$(convert_to_bytes "$volume_size")
c_drive_size=$(df /mnt/c | awk 'NR==2 {print $2}')

result=$(echo "scale=5; $volume_size_bytes * 100 / $c_drive_size" | bc)

echo "Volumes take up $result% of disc space"

