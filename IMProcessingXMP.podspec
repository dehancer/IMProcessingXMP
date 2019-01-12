Pod::Spec.new do |s|
    s.name         = "IMProcessingXMP"
    
    s.version      = "5.6.0"
    
    s.summary      = "Adobe’s XMP SDKs wrapper for iOS and OS X"
    
    s.description  = "Adobe’s Extensible Metadata Platform (XMP) is a file labeling technology that lets you embed metadata into files themselves during the content creation process. With an XMP enabled application, your workgroup can capture meaningful information about a project (such as titles and descriptions, searchable keywords, and up-to-date author and copyright information) in a format that is easily understood by your team as well as by software applications, hardware devices, and even file formats. Best of all, as team members modify files and assets, they can edit and update the metadata in real time during the workflow."

    s.homepage     = "https://www.adobe.com/products/xmp.html"
    
    s.license         = { :type => 'BSD', :file => 'LICENSE.txt' }

    s.source       = { :git => "https://github.com/dehancer/IMProcessingXMP.git", :tag => "#{s.version}" }
    
    s.authors       =  {'Denn Nevera' => 'denn.nevera@gmail.com'}
    
    s.osx.deployment_target   = '10.11'
    
    s.osx.source_files         = 'ImageMeta/*.{h,m,mm}', 'include-macos/xmpsdk/**/*.{h,hpp}'
    s.osx.public_header_files  = 'ImageMeta/*.{h,hpp}'
    s.osx.private_header_files = 'include-macos/xmpsdk/**/*.h'

    s.osx.header_dir          = 'xmpsdk'
    #s.header_mappings_dir     = 'include-macos/xmpsdk'
    s.osx.preserve_paths      = 'lib-macos/release/libXMPCoreStatic.a', 'lib-macos/release/libXMPFilesStatic.a'
    s.osx.vendored_libraries  = 'lib-macos/release/libXMPCoreStatic.a', 'lib-macos/release/libXMPFilesStatic.a'
    
    s.libraries = 'XMPCoreStatic', 'XMPFilesStatic'
    
    s.requires_arc = false
    
#    s.compiler_flags = '-Wno-format',
#    '-Wno-unused-variable',
#    '-Wno-unused-function',
#    '-Wno-unused-parameter',
#    '-Wnon-virtual-dtor',
#    '-Woverloaded-virtual',
#    '-DMAC_ENV=1'

    s.pod_target_xcconfig = { 'OTHER_CFLAGS' => '-arch x86_64 -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -stdlib=libc++ -Wno-trigraphs -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Wunreachable-code -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wshadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wno-float-conversion -Wnon-literal-null-conversion -Wobjc-literal-conversion -Wshorten-64-to-32 -Wno-newline-eof -Wno-c++11-extensions -DENABLE_CPP_DOM_MODEL=1 -DXML_STATIC=1 -DHAVE_EXPAT_CONFIG_H=1 -DXMP_StaticBuild=1 -DXMP_64=1-Wno-sign-conversion -Winfinite-recursion -Wmove -Wcomma -Wblock-capture-autoreleasing -Wstrict-prototypes -Wrange-loop-analysis -Wno-semicolon-before-method-body -funsigned-char -fshort-enums -fno-common -Wall -Wextra -Wno-missing-field-initializers -Wno-shadow -Wno-reorder -Wnon-virtual-dtor -Woverloaded-virtual -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -fstack-protector'}
    
    # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SRCROOT)/include-macos/xmpsdk', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited)'}
end
