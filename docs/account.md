## Account

* [List accounts](#list)
* [Find account](#find)

### List

* List all accounts
* This command shows id, state, date created and organization name

```shell
NAME
    list - list accounts

USAGE
    3scale account list <remote>

DESCRIPTION
    List all accounts

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml

OPTIONS FOR ACCOUNT
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  /root/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### Find

* Find accounts. 
* Several other options can be set. Check `usage`

```shell
NAME
    find - find account

USAGE
    3scale account find [opts] <remote> <text>

DESCRIPTION
    Find account by email, provider key or service token

OPTIONS
    -a --print-all                Print all the account info

OPTIONS FOR ACCOUNT
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  /root/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

