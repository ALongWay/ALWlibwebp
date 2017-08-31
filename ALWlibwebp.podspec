Pod::Spec.new do |s|
  s.name             = 'ALWlibwebp'
  s.version          = '0.1.0'
  s.summary          = 'The libwebp of Google. Version is 0.6.0 .'

  s.homepage         = 'https://github.com/ALongWay/ALWlibwebp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lisong' => '370381830@qq.com' }
  s.source           = { :git => 'https://github.com/ALongWay/ALWlibwebp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.compiler_flags = '-D_THREAD_SAFE'
  s.requires_arc = false

  s.subspec 'webp' do |ss|
    ss.header_dir = 'webp'
    ss.source_files = 'ALWlibwebp/Classes/src/webp/*.h'
  end

  s.subspec 'core' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/utils/*.{h,c}', 'ALWlibwebp/Classes/src/dsp/*.{h,c}', 'ALWlibwebp/Classes/src/enc/*.{h,c}', 'ALWlibwebp/Classes/src/dec/*.{h,c}'
    ss.dependency 'ALWlibwebp/webp'
  end

  s.subspec 'utils' do |ss|
    ss.dependency 'ALWlibwebp/core'
  end

  s.subspec 'dsp' do |ss|
    ss.dependency 'ALWlibwebp/core'
  end

  s.subspec 'enc' do |ss|
    ss.dependency 'ALWlibwebp/core'
  end

  s.subspec 'dec' do |ss|
    ss.dependency 'ALWlibwebp/core'
  end

  s.subspec 'demux' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/demux/*.{h,c}'
    ss.dependency 'ALWlibwebp/core'
  end

  s.subspec 'mux' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/mux/*.{h,c}'
    ss.dependency 'ALWlibwebp/core'
  end

end
