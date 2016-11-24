install:
	install -d -m 755 ${DESTDIR}/opt/pcapgazer
	install -d -m 755 ${DESTDIR}/opt/pcapgazer/Output
	install -d -m 755 ${DESTDIR}/var/log/pcapgazer
	install -d -m 755 ${DESTDIR}/etc/logrotate.d
	install -m 755 src/pcapgazer*  ${DESTDIR}/opt/pcapgazer/
	install -m 644 src/Output/* ${DESTDIR}/opt/pcapgazer/Output
	install -m 755 src/config.ini  ${DESTDIR}/opt/pcapgazer/
	install -m 755 logrotate.d/pcapgazer  ${DESTDIR}/etc/logrotate.d/
