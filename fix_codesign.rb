require 'xcodeproj'

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
project.build_configurations.each do |config|
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGN_IDENTITY'] = ''
  config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
end
project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
  end
end
project.save
puts "Modified project.pbxproj successfully."
