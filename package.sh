#!/bin/sh
set -e

# compile for version
make
if [ $? -ne 0 ]; then
    echo "make error"
    exit 1
fi

raw_version=`./bin/frps --version`
case "$raw_version" in
    v*) release_version="$raw_version" ;;
    *) release_version="v${raw_version}" ;;
esac

echo "build version: $release_version"

# cross_compiles
make -f ./Makefile.cross-compiles

rm -rf ./release/packages
mkdir -p ./release/packages

os_all='linux windows darwin freebsd openbsd'
arch_all='386 amd64 arm arm64 mips64 mips64le mips mipsle riscv64 loong64'
extra_all='_ hf'

cd ./release

for os in $os_all; do
    for arch in $arch_all; do
        for extra in $extra_all; do
            suffix="${os}_${arch}"
            if [ "x${extra}" != x"_" ]; then
                suffix="${os}_${arch}_${extra}"
            fi

            archive_name="cnfrp_${release_version}_${suffix}"
            package_path="./packages/${archive_name}"

            if [ "x${os}" = x"windows" ]; then
                if [ ! -f "./frpc_${os}_${arch}.exe" ]; then
                    continue
                fi
                if [ ! -f "./frps_${os}_${arch}.exe" ]; then
                    continue
                fi
                mkdir "${package_path}"
                mv "./frpc_${os}_${arch}.exe" "${package_path}/frpc.exe"
                mv "./frps_${os}_${arch}.exe" "${package_path}/frps.exe"
            else
                if [ ! -f "./frpc_${suffix}" ]; then
                    continue
                fi
                if [ ! -f "./frps_${suffix}" ]; then
                    continue
                fi
                mkdir "${package_path}"
                mv "./frpc_${suffix}" "${package_path}/frpc"
                mv "./frps_${suffix}" "${package_path}/frps"
            fi

            cp ../LICENSE "${package_path}"
            cp -f ../conf/frpc.toml "${package_path}"
            cp -f ../conf/frps.toml "${package_path}"

            cd ./packages
            if [ "x${os}" = x"windows" ]; then
                zip -rq "${archive_name}.zip" "${archive_name}"
            else
                tar -zcf "${archive_name}.tar.gz" "${archive_name}"
            fi
            cd ..
            rm -rf "${package_path}"
        done
    done
done

cd -
