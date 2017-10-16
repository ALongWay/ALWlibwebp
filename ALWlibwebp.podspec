Pod::Spec.new do |s|
  s.name             = 'ALWlibwebp'
  s.version          = '0.1.4'
  s.summary          = 'The libwebp of Google. Version is 0.6.0 .'

  s.homepage         = 'https://github.com/ALongWay/ALWlibwebp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lisong' => '370381830@qq.com' }
  s.source           = { :git => 'https://github.com/ALongWay/ALWlibwebp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.subspec 'Decoder' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/Decoder/*.{h,m}'
    ss.dependency 'ALWlibwebp/libwebp'
  end

  s.subspec 'libwebp' do |webp|
    webp.compiler_flags = '-D_THREAD_SAFE'
    webp.requires_arc = false

    webp.subspec 'webp' do |ss|
      ss.header_dir = 'webp'
      ss.source_files = 'ALWlibwebp/Classes/libwebp/src/webp/*.h'
    end

    webp.subspec 'core' do |ss|
      ss.source_files = 'ALWlibwebp/Classes/libwebp/src/utils/*.{h,c}', 'ALWlibwebp/Classes/libwebp/src/dsp/*.{h,c}', 'ALWlibwebp/Classes/libwebp/src/enc/*.{h,c}', 'ALWlibwebp/Classes/libwebp/src/dec/*.{h,c}'
      ss.dependency 'ALWlibwebp/libwebp/webp'
    end

    webp.subspec 'utils' do |ss|
      ss.dependency 'ALWlibwebp/libwebp/core'
    end

    webp.subspec 'dsp' do |ss|
      ss.dependency 'ALWlibwebp/libwebp/core'
    end

    webp.subspec 'enc' do |ss|
      ss.dependency 'ALWlibwebp/libwebp/core'
    end

    webp.subspec 'dec' do |ss|
      ss.dependency 'ALWlibwebp/libwebp/core'
    end

    webp.subspec 'demux' do |ss|
      ss.source_files = 'ALWlibwebp/Classes/libwebp/src/demux/*.{h,c}'
      ss.dependency 'ALWlibwebp/libwebp/core'
    end

    webp.subspec 'mux' do |ss|
      ss.source_files = 'ALWlibwebp/Classes/libwebp/src/mux/*.{h,c}'
      ss.dependency 'ALWlibwebp/libwebp/core'
    end
  end

end
