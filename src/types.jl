
struct LDAPConnection
    handle::Ptr{Cvoid}
    url::String
end

# typedef struct ldap_url_desc
struct LDAPURLDesc
    lud_next::Ptr{Cvoid}
    lud_scheme::Cstring
    lud_host::Cstring
    lud_port::Cint
    lud_dn::Cstring
    lud_attrs::Ptr{Ptr{UInt8}}
    lud_scope::Cint
    lud_filter::Cstring
    lud_exts::Ptr{Ptr{UInt8}}
    lud_crit_exts::Cint
end

struct URL
    scheme::String
    host::String
    port::Int
    dn::Union{Nothing, String}
    attrs::Vector{String}
    scope::Int
    filter::Union{Nothing, String}
    exts::Vector{String}
    crit_exts::Int
end

Base.:(==)(ua::URL, ub::URL) = ua.scheme == ub.scheme && ua.host == ub.host && ua.port == ub.port && ua.dn == ub.dn && ua.attrs == ub.attrs && ua.scope == ub.scope && ua.filter == ub.filter && ua.exts == ub.exts && ua.crit_exts == ub.crit_exts

abstract type AuthenticationResult end

struct AuthOk <: AuthenticationResult
    uri::String
    who::String
end

struct AuthErr <: AuthenticationResult
    uri::String
    who::String
    err_code::Cint
end
