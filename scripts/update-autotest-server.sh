#!/bin/bash

cd /usr/local/autotest
# git pull origin
sudo chown -R autotest:autotest /usr/local/autotest
python /usr/local/autotest/utils/build_externals.py
python /usr/local/autotest/database/migrate.py sync
python /usr/local/autotest/utils/compile_gwt_clients.py -a
python /usr/local/autotest/frontend/manage.py syncdb
chmod -R o+r /usr/local/autotest
find /usr/local/autotest/ -type d | xargs chmod o+x
chmod o+x /usr/local/autotest/tko/*.cgi
sudo apache2ctl restart
/usr/local/autotest/utils/test_importer.py
#/usr/local/autotest/scheduler/monitor_db.py /usr/local/autotest/results

#reboot
