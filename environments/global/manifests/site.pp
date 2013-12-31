case $kernel
{
    'windows':
    {
        hiera_include( windows_classes )
    }
    'linux':
    {
        hiera_include( linux_classes )
    }
}

