############################################################
# Class: kernel
#
# Description:
#  This will blacklist Linux kernel modules, disable
#  interactive boot, disable core dumps, require a password
#  for single user mode, and disable ipv6 among other
#  things.
#
# Variables:
#  server
#
# Facts:
#  None
#
# Files:
#  None
#
# Templates:
#  None
#
# Dependencies:
#  None
############################################################
class kernel {
  kernel::disableModule{ 'Disable Cramfs':
    module => 'cramfs',
  }
  kernel::disableModule{ 'Disable freevxfs':
    module => 'freevxfs',
  }
  kernel::disableModule{ 'Disable jffs2':
    module => 'jffs2',
  }
  kernel::disableModule { 'Disable hfs':
    module => 'hfs',
  }
  kernel::disableModule { 'Disable hfsplus':
    module => 'hfsplus',
  }
  kernel::disableModule { 'Disable squashfs':
    module => 'squashfs',
  }
  kernel::disableModule { 'Disable udf':
    module => 'udf',
  }
  #RHEL-06-000315
  kernel::disableModule { 'Disable bluetooth':
    module => 'bluetooth',
  }
  #RHEL-06-000315
  kernel::disableModule { 'net-pf-31':
    module => 'net-pf-31',
  }
  #RHEL-06-000124
  kernel::disableModule { 'Disable dccp':
    module => 'dccp',
  }
  #RHEL-06-000125
  kernel::disableModule { 'Disable sctp':
    module => 'sctp',
  }
  #RHEL-06-000126
  kernel::disableModule { 'Disable rds':
    module => 'rds',
  }
  #RHEL-06-000127
  kernel::disableModule { 'Disable tipc':
    module => 'tipc',
  }
  #RHEL-06-000503
  kernel::disableModule { 'Disable usb-storage':
    module => 'usb-storage',
  }

  #RHEL-06-000308
  augeas { 'Disable Core Dumps for All Users':
    context => '/files/etc/security/limits.conf',
    changes => [
      "rm domain[.='*'][./type='hard' and ./item='core']",
      "set domain[last() + 1] '*'",
      "set domain[last()]/type 'hard'",
      "set domain[last()]/item 'core'",
      'set domain[last()]/value 0',
    ],
  }
  # RHEL-06-000017
  augeas { 'Ensure SELinux Not Disabled in /etc/grub.conf':
    context => '/files/etc/grub.conf',
    lens    => 'grub.lns',
    incl    => '/etc/grub.conf',
    changes => "rm title/kernel/selinux[.='0']",
  }
  augeas { 'Ensure SELinux Enforcing Not Disabled in /etc/grub.conf':
    context => '/files/etc/grub.conf',
    lens    => 'grub.lns',
    incl    => '/etc/grub.conf',
    changes => "rm title/kernel/enforcing[.='0']",
  }
  #RHEL-06-000070
  augeas { 'Disable Interactive Boot':
    context => '/files/etc/sysconfig/init',
    lens    => 'shellvars.lns',
    incl    => '/etc/sysconfig/init',
    changes => 'set PROMPT no',
  }
  #RHEL-06-000098
  augeas { 'Disable Functionality of IPv6':
    context => '/files/etc/modprobe.d/disabled.conf',
    lens    => 'modprobe.lns',
    incl    => '/etc/modprobe.d/disabled.conf',
    changes => [
      "set options[. = 'ipv6'] 'ipv6'",
      "set options[. = 'ipv6']/disable '1'",
    ],
  }

}

define kernel::disableModule ( $module = '' )
{
  augeas { $name:
    context => '/files/etc/modprobe.d/disabled.conf',
    lens    => 'modprobe.lns',
    incl    => '/etc/modprobe.d/disabled.conf',
    changes => [
      "set install[. = '${module}'] '${module}'",
      "set install[. = '${module}']/command '/bin/false'",
    ];
  }
}
