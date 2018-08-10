# Juicy Potato
*A sugared version of [RottenPotatoNG][1], with a bit of juice, i.e. **another Local Privilege Escalation tool, from a Windows Service Accounts to NT AUTHORITY\SYSTEM***

By [@decoder_it](https://twitter.com/decoder_it) & [@giutro](https://twitter.com/Giutro)

## Summary
[RottenPotatoNG][1] and its [variants][6] leverages the privilege escalation chain based on [`BITS`][3] [service](https://github.com/breenmachine/RottenPotatoNG/blob/4eefb0dd89decb9763f2bf52c7a067440a9ec1f0/RottenPotatoEXE/MSFRottenPotato/MSFRottenPotato.cpp#L126
) having the MiTM listener on `127.0.0.1:6666`. During a Windows build review we found a setup where `BITS` was was intentionally disabled and port `6666` was taken.

We decided to weaponize [RottenPotatoNG][1]: **Say hello to Juicy Potato**.

> For the theory, see [Rotten Potato - Privilege Escalation from Service Accounts to SYSTEM][4] and follow the chain of links and references.

We discovered than, other than `BITS` there are a several COM servers we can abuse. They just need to:
1. be instantiable by the current user, normally a "service user" which has impersonation privileges)
2. implement the `IMarshal` interface
3. run as an elevated user (SYSTEM, Administrator, ...)

After some testing we obtained and tested an extensive list of [interesting CLSID's](Docs) on several Windows versions.

## Juicy details
JuicyPotato allows you to:

+ **Target CLSID**<br>
_pick any CLSID you want. [Here](Docs) you can find the list organized by OS._

+ **COM Listening port**<br>
_define COM listening port you prefer (instead of the marshalled hardcoded 6666)_

+ **COM Listening IP address**<br>
_bind the server on any IP_

+ **Process creation mode**<br>
_depending on the impersonated user's privileges you can choose from:_
   - `CreateProcessWithToken` (needs `SeImpersonate`)
   - `CreateProcessAsUser` (needs `SeAssignPrimaryToken`)
   - `both`


+ **Process to launch**<br>
_launch an executable or script if the exploitation succeeds_

+ **Process Argument**<br>
_customize the launched process arguments_

+ **RPC Server address**<br>
_for a stealthy approach you can authenticate to an external RPC server_

+ **RPC Server port**<br>
_useful if you want to authenticate to an external server and firewall is blocking port `135`..._

+ **TEST mode**<br>
_mainly for testing purposes, i.e. testing CLSIDs. It creates the DCOM and prints the user of token. See [here for testing](Docs/Test)_


## Usage

```
T:\>JuicyPotato.exe
JuicyPotato v0.1

Mandatory args:
-t createprocess call: <t> CreateProcessWithTokenW, <u> CreateProcessAsUser, <*> try both
-p <program>: program to launch
-l <port>: COM server listen port


Optional args:
-m <ip>: COM server listen address (default 127.0.0.1)
-a <argument>: command line argument to pass to program (default NULL)
-k <ip>: RPC server ip address (default 127.0.0.1)
-n <port>: RPC server listen port (default 135)
-c <{clsid}>: CLSID (default BITS:{4991d34b-80a1-4291-83b6-3328366b9097})
-z only test CLSID and print token's user
```


## Example

```
T:\>JuicyPotato.exe -t * -p c:\Windows\System32\cmd.exe -l 31337

Testing {4991d34b-80a1-4291-83b6-3328366b9097} 31337
......
[+] authresult 0
{4991d34b-80a1-4291-83b6-3328366b9097};NT AUTHORITY\SYSTEM

[+] CreateProcessWithTokenW OK
```


## Final thoughts
If the user has `SeImpersonate` or `SeAssignPrimaryToken` privileges then you are **SYSTEM**.

It's nearly impossible to prevent the abuse of all these COM Servers. You could think to modify the permissions of these objects via `DCOMCNFG` but good luck, this is gonna be challenging.

The actual solution is to protect sensitive accounts and applications which run under the `* SERVICE` accounts.
Stopping `DCOM` would certainly inhibit this exploit but could have a serious impact on the underlying OS.


## References

* [Rotten Potato - Privilege Escalation from Service Accounts to SYSTEM][4]
* [Windows: DCOM DCE/RPC Local NTLM Reflection Elevation of Privilege][5]
* [Potatoes and Tokens](https://decoder.cloud/2018/01/13/potato-and-tokens/)
* [The lonely Potato](http://decoder.cloud/2017/12/23/the-lonely-potato/)
* [Social Engineering the Windows Kernel by James Forshaw](https://www.slideshare.net/Shakacon/social-engineering-the-windows-kernel-by-james-forshaw)

[1]: https://github.com/breenmachine/RottenPotatoNG
[2]: https://decoder.cloud/2017/12/23/the-lonely-potato/
[3]: https://msdn.microsoft.com/en-us/library/windows/desktop/bb968799(v=vs.85).aspx
[4]: https://foxglovesecurity.com/2016/09/26/rotten-potato-privilege-escalation-from-service-accounts-to-system/
[5]: https://bugs.chromium.org/p/project-zero/issues/detail?id=325&redir=1
[6]:https://github.com/decoder-it/lonelypotato
