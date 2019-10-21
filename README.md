# iOSDyldIntegrityBypass
Guide and Tweak on how to bypass applications compiled with Integrity checks. Designed for Jailed ios tweaks.

## General Overview
Applications compiled with iOS dynamic linker (Dyld) file integrity protection will crash on launch when working with a cracked and/or resigned binary. Since we require a decrypted binary to inject any tweaks, preparation on how to bypass these basic FIP protocols is critical for both Jailbreak and Jailed tweak developers.

### Identifying an application is crashing due to Dyld?
You have a cracked/decrypted binary, you injected your tweak, but the application crashes on launch. Check out your devices crash log. If the crash log show's the main thread never makes it past `_dyld_start`, guess what!? Dyld is killing you!?
  
### What is Dyld doing?
Thankfully Dyld's source, like much of Apple's packages, is open and available directly via apple at either. https://github.com/opensource-apple or https://opensource.apple.com. 
This repo isn't to break down how dyld operates, but it is HIGHLY recommended you become familiar with the process flow for opening and executing a binary of iOS systems if you want to have a proper understanding of how it flags you, and why this bypass works.

Pay attention to `ImageLoaderMachO.h` and trace back through dyld's source to get a good idea of what's going on.

### How do I bypass this?
If you were to use fishhook or another method to rebind symbols on runtime, and monitored open(), read(), close() you will find 2 calls that should stand out. 
1) Open() called on original binary image
2) Read() for 4 Mem Pages (0x4000 Bytes on iOS 64 bit systems)
3) Read() for 1 Mem Page (0x1000 Bytes)
4) close() original binary image.

This initial read pulls *the first* 4 memory pages from the binary. iOS could then validate each page based on a hash, and also now has the files header and all load commands, and can use these to ensure the filesize, and location of target data is in proper alignment and valid. This includes checking the LC_ENCRYPTION_INFO_64 load command, to determine whether or not the file needs decrypted from Apple's FairPlay DRM as any official App store application would, and the LC_CODE_SIGNATURE_64 load command, which contains the offset and size of the binaries original code signature.
