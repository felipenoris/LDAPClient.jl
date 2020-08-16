
# LDAPClient.jl

[![License][license-img]](LICENSE)
[![travis][travis-img]][travis-url]
[![appveyor][appveyor-img]][appveyor-url]
[![codecov][codecov-img]][codecov-url]

[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[travis-img]: https://img.shields.io/travis/felipenoris/LDAPClient.jl/master.svg?logo=travis&label=Linux+/+macOS&style=flat-square
[travis-url]: https://travis-ci.org/felipenoris/LDAPClient.jl
[appveyor-img]: https://img.shields.io/appveyor/ci/felipenoris/ldapclient-jl/master.svg?logo=appveyor&label=Windows&style=flat-square
[appveyor-url]: https://ci.appveyor.com/project/felipenoris/ldapclient-jl/branch/master
[codecov-img]: https://img.shields.io/codecov/c/github/felipenoris/LDAPClient.jl/master.svg?label=codecov&style=flat-square
[codecov-url]: http://codecov.io/github/felipenoris/LDAPClient.jl?branch=master

A Julia client for LDAP (Lightweight Directory Access Protocol) based on [OpenLDAP](https://www.openldap.org/) library.

## Installation

```julia
pkg> add LDAPClient
```

## Tutorial

### Authentication

This implements the use-case of checking if a username and password are valid or not.
`r` will be either an `AuthOk` for successful authentication, or `AuthErr` when the
password is wrong or any other error happened.

```julia
r = LDAPClient.authenticate("ldap://ldap.server.net", "my-username", "my-password")
```

### Bind and Unbind

Usually the user needs to bind to a LDAP connection before running queries.
The following example shows how to create a connection, bind to it, and unbind when you're finished with it.

```julia
conn = LDAPClient.LDAPConnection("ldap://ldap.server.net") # this will not connect to the server yet
LDAPClient.simple_bind(conn, "my-username", "my-password") # here we actually get to connect to the server
# do stuff
LDAPClient.unbind(conn)
```

### Running queries

Use `LDAPClient.search` to perform queries on your LDAP server.

```julia
search(ldap::LDAPConnection, base::AbstractString, scope::LDAPScope;
        filter::Union{Nothing, AbstractString}=nothing,
        attr_desc_only::Bool=false,
        size_limit::Integer=-1) :: MessageChain
```

`scope` can be one of these values: `LDAP_SCOPE_BASE`, `LDAP_SCOPE_ONELEVEL`, `LDAP_SCOPE_SUBTREE`, `LDAP_SCOPE_CHILDREN`.

The following example queries for users, filtering only results that match users named `USER1` or `USER2`.

```julia
search_string = "CN=Users,DC=server,DC=net" # will query Users on domain server.net
scope = LDAPClient.LDAP_SCOPE_ONELEVEL
chain = LDAPClient.search(conn, search_string, scope, filter="(|(name=USER1)(name=USER2))")
```

The `chain` output is a collection of messages.
Each message can be an `Entry`, a `Reference` or a `Result`.

We can count how many messages of each kind we have with `count_messages(chain)`, `count_entries(chain)` or `count_references(chain)`.

We can iterate messages of each kind with `each_message(chain)`, `each_entry(chain)`, `each_reference(chain)`.

For `Entry` messages, we can inspect its attributes. The following shows a complete example.

```julia
conn = LDAPClient.LDAPConnection("ldap://ldap.server.net")
LDAPClient.simple_bind(conn, "my-username", "my-password")

search_string = "CN=Users,DC=server,DC=net" # will query Users on domain server.net
scope = LDAPClient.LDAP_SCOPE_ONELEVEL
chain = LDAPClient.search(conn, search_string, scope, filter="(|(name=USER1)(name=USER2))")

for entry in LDAPClient.each_entry(chain)
    println("Reading attributes from user $(entry["name"])")
    for attr in LDAPClient.each_attribute(entry)
        println(attr)
    end
end

LDAPClient.unbind(conn)
```

This example outputs something like this.

```
Reading attributes from user ["USER1"]
LDAPClient.Attribute("objectClass", ["top", "person", "organizationalPerson", "user"])
LDAPClient.Attribute("cn", ["USER1"])
LDAPClient.Attribute("title", ["Manager"])
```

## References

* [LDAP.com](https://ldap.com/)

* [OpenLDAP](https://www.openldap.org/)
