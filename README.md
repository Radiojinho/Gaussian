# Gaussian
gaussian script
(업글버전) 모든 파일에 freq을 검색해서 첫번째줄부터 세번재줄까지 출력해주는 .sh 스크립트 

#!/bin/bash

# 파일 수 초기화
file_count=0
imaginary_count=0

for file in *.log
do
    echo "File: $file"
    imaginary_exist="no"
    freq_count=0

    # 주파수 출력 및 이메지너리 프리퀀시 검사
    grep "Frequencies" "$file" | awk '{
        for(i=3; i<=NF; i++) {
            if ($i ~ /^-?[0-9]/) {
                printf "%20.4f", $i;
                if ($i < 0) {
                    imaginary_exist="yes"
                }
                freq_count++
                if (freq_count % 3 == 0) {
                    print "";  # 세 개의 주파수 값을 출력한 후 줄바꿈
                }
                if (freq_count == 9) {
                    exit;  # 총 아홉 개의 주파수 값을 출력한 후 종료
                }
            }
        }
    } END {
        if (freq_count % 3 != 0) {
            print "";  # 남아있는 주파수 값에 대한 줄바꿈
        }
        if (imaginary_exist == "yes") {
            exit 1
        } else {
            exit 0
        }
    }'

    # 이메지너리 프리퀀시가 있는 경우 카운트 증가
    if [ $? -eq 1 ]; then
        imaginary_count=$((imaginary_count + 1))
    fi

    # 처리한 파일 수 증가
    file_count=$((file_count + 1))

    echo "--------------------------"
done

# 이메지너리 프리퀀시가 있는 파일 목록 출력
echo "Total files with imaginary frequencies: $imaginary_count"

# 최종 요약 출력
echo "Total files checked: $file_count"
