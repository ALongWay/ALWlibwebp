Pod::Spec.new do |s|
  s.name             = 'ALWlibwebp'
  s.version          = '0.1.0'
  s.summary          = 'The libwebp of google.'

  s.homepage         = 'https://github.com/ALongWay/ALWlibwebp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lisong' => '370381830@qq.com' }
  s.source           = { :git => 'https://github.com/ALongWay/ALWlibwebp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.subspec 'dec' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/dec/*.{h,c}'
  end

  s.subspec 'demux' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/demux/*.{h,c}'
  end

  s.subspec 'dsp' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/dsp/*.{h,c}'
  end

  s.subspec 'utils' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/utils/*.{h,c}'
  end

  s.subspec 'webp' do |ss|
    ss.source_files = 'ALWlibwebp/Classes/src/webp/*.{h,c}'
  end

end
