# /etc/profile

# System wide environment and startup programs, for login setup
# Functions and aliases go in /etc/bashrc

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}


if [ -x /usr/bin/id ]; then
    if [ -z "$EUID" ]; then
        # ksh workaround
        EUID=`/usr/bin/id -u`
        UID=`/usr/bin/id -ru`
    fi
    USER="`/usr/bin/id -un`"
    LOGNAME=$USER
    MAIL="/var/spool/mail/$USER"
fi

# Path manipulation
if [ "$EUID" = "0" ]; then
    pathmunge /usr/sbin
    pathmunge /usr/local/sbin
else
    pathmunge /usr/local/sbin after
    pathmunge /usr/sbin after
fi

HOSTNAME=`/usr/bin/hostname 2>/dev/null`
HISTSIZE=1000
if [ "$HISTCONTROL" = "ignorespace" ] ; then
    export HISTCONTROL=ignoreboth
else
    export HISTCONTROL=ignoredups
fi

export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL

# By default, we want umask to get set. This sets it for login shell
# Current threshold for system reserved uid/gids is 200
# You could check uidgid reservation validity in
# /usr/share/doc/setup-*/uidgid file
if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
    umask 002
else
    umask 022
fi

for i in /etc/profile.d/*.sh /etc/profile.d/sh.local ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then 
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done

unset i
unset -f pathmunge

export WATCHMEN_BASE_URL='http://watchmen.local'
export WATCHMEN_WEB_PORT='8080'
export WATCHMEN_ADMINS='GMAIL ID'
#export WATCHMEN_GOOGLE_ANALYTICS_ID='your-GA-ID'
export WATCHMEN_WEB_NO_AUTH='true'
export WATCHMEN_AUTH_NODEMAILER_PORT=25
export WATCHMEN_AUTH_NODEMAILER_HOST=192.168.1.99
export WATCHMEN_AUTH_NODEMAILER_USER=<username>
export WATCHMEN_AUTH_NODEMAILER_PASS=<Pasword here>


export WATCHMEN_SLACK_NOTIFICATION_EVENTS='service-back new-outage'
export WATCHMEN_SLACK_NOTIFICATION_URL='Web hook url get from slack'
export WATCHMEN_SLACK_NOTIFICATION_CHANNEL='#watchmen'
export WATCHMEN_SLACK_NOTIFICATION_USERNAME='falcon'
export WATCHMEN_SLACK_NOTIFICATION_ICON_EMOJI=':doge2:'

