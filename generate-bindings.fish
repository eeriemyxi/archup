#!/bin/fish

# odin-c-bindgen as of now doesn't support absolute URLs:
# https://github.com/karl-zylinski/odin-c-bindgen/blob/46d8c34b17687db26e8dcd671ce65073d7f8c712/src/main.odin#L16
# So, we copy the system files over to this directory to include it.
#
# As for why we are not cloning pacutils and linking against it is that some
# distribitions like CachyOS patch pacutils, including its structs,
# so we end up with segfaults. This also means that the package
# must be compiled from source on the user's PC or distribution to
# guarantee its reliability
mkdir ./pacutils/includes
cp /usr/include/pacutils.h ./pacutils/includes/
cp /usr/include/pacutils/* ./pacutils/includes/

bindgen ./alpm-auto/
bindgen ./pacutils/

function subs --argument-names pattern file
  echo === FILE $file : $pattern ===
  set prev_contents (cat $file | string collect)
  sed -i $pattern $file
  echo $prev_contents | diff - $file
end

for f in ./pacutils/pacutils/**.odin ./alpm-auto/alpm/**.odin;
  subs "s/:\s\+^File\([\,,)]\)/: ^libc.FILE\1/g
        s/-> ^File\([ ,\,]\)/-> ^libc.FILE\1/g

        s/:\s\+Uid/: u32/g
        s/:\s\+Mode/: u32/g

        s/:\s\+^Tm/: ^libc.tm/g
        s/:\s\+Tm/: libc.tm/g
        s/-> \+^Tm/-> ^libc.tm/g

        s/: \+^Stat/: ^linux.Stat/g" $f
end

for f in ./pacutils/pacutils/**.odin;
  subs "s/:\s\+^Alpm_Depend/: ^alpm.Depend/g
        s/\s\+^Alpm_Pkg/ ^alpm.Pkg/g
        s/\s\+^Alpm_Db/ ^alpm.Db/g
        s/\s\+^Alpm_File/ ^alpm.File/g
        s/\s\+^Alpm_Filelist/ ^alpm.Filelist/g
        s/\s\+^Alpm_Handle/ ^alpm.Handle/g
        s/\s\+Alpm_Progress/ ^alpm.Progress/g
        s/\s\+Alpm_Download_Event_Type/ ^alpm.Download_Event_Type/g
        s/\s\+^Alpm_Question/ ^alpm.Question/g
        s/\s\+^Alpm_Event/ ^alpm.Event/g

        s/\s\+^Alpm_List/ ^alpm.List/g
        s/\s\+^^Alpm_List/ ^^alpm.List/g" $f
end
