# encoding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)

# Note: the password may be omitted, since the 'vagrant' user
# is setup with passphrase-less SSH keys.
module Backup
describe Storage::SFTP do

  it 'cycles stored packages' do
    create_model :my_backup, <<-EOS
      Backup::Model.new(:my_backup, 'a description') do
        split_into_chunks_of 1 # 1MB

        archive :my_archive do |archive|
          archive.add '~/test_data'
        end

        store_with SFTP do |sftp|
          sftp.ip = 'localhost'
          sftp.username = 'vagrant'
          sftp.password = 'vagrant'
          sftp.path = '~/Storage'
          sftp.keep = 2
        end
      end
    EOS

    job_a = backup_perform :my_backup
    expect( job_a.package.files.count ).to be(2)

    job_b = backup_perform :my_backup
    expect( job_b.package.files.count ).to be(2)
    expect( job_a.package.exist? ).to be_truthy

    job_c = backup_perform :my_backup
    expect( job_c.package.files.count ).to be(2)
    expect( job_b.package.exist? ).to be_truthy
    expect( job_a.package.removed? ).to be_truthy
  end
end
end
