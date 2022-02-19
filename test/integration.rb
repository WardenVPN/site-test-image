# ioncube
describe file('/usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so') do
    its('mode') { should cmp '0664' }
    it { should exist }
    it { should be_owned_by 'root' }
end
describe file('/usr/local/etc/php/conf.d/a_ioncude.ini') do
    its('mode') { should cmp '0644' }
    it { should exist }
    it { should be_owned_by 'root' }
end
describe ini('/usr/local/etc/php/conf.d/a_ioncude.ini') do
    its('zend_extension') { should eq '/usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so' }
  end

# composer
describe file('/usr/local/bin/composer') do
    its('mode') { should cmp '0755' }
    it { should exist }
    it { should be_owned_by 'root' }
end

[
    'libfreetype6-dev',
    'libjpeg62-turbo-dev',
    'libmcrypt-dev',
    'libpng-dev',
    'libsqlite3-dev',
    'libcurl4-gnutls-dev',
].each do |pkg|
    describe package(pkg) do
        it { should be_installed }
      end      
end

[
    'php -m',
    'php -m | grep ionCube24',
    'php -m | grep iconv',
    'php -m | grep mysqli',
    'php -m | grep pdo',
    'php -m | grep pdo_mysql',
    'php -m | grep pdo_sqlite',
    'php -m | grep gd',
    'php -m | grep pcntl',
    'php -m | grep curl',
    'php -m | grep bcmath',
    'php -m | grep \'Zend OPcache\'' # opcache
]. each do |cmd|
    describe command(cmd) do
        its('exit_status') { should eq 0 }
    end
end