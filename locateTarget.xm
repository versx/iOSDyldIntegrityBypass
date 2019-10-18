// TRGoCPftF
// Tweak to Identify location of pages in memory needed for dyld Integrity
// bypass.

// Compile to a dylib or use in a Theos Jailed Tweak and inject
// Watch the Sys log and grab what you need

#import <dlfcn.h>
#import <fcntl.h>
#import <fishhook.h>

#pragma mark original Imp pointers

static ssize_t (*orig_read)(int, void*, size_t);

ssize_t dis_read(int fildes, void *buf, size_t nbyte){

  // Uncomment This if you want to inspect the size of all reads
  // If you add a hook and swap imp for open, you can log out what
  // image has the file descriptor passed here, ensure you're looking
  // at your target binary's image.

  /* NSLog(@"[getData] - file: %i\nsize: %lX",fildes,nbyte); */

  if(nbyte==0x1000){
    uint64_t data;
    ssize_t ret = 0x1000;
    orig_read(fildes,buf,nbyte);
    memcpy(&data,buf,sizeof(data));
    NSLog(@"[getData] - Go Look For This in Binary => %llx",data);
    NSLog(@"[getData] - Don't forget its little endian so those chunks of bytes are backawards btw");
    return ret;
  }
  return orig_read(fildes,buf,nbyte);
}


#pragma mark GetAllUpInThere
%ctor {
  rebind_symbols((struct rebinding[1]){
        {"read", (void *)dis_read, (void **)&orig_read}
      }, 1);
}
