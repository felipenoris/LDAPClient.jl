
mutable struct LDAPConnection
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

mutable struct MessageChain
    handle::Ptr{Cvoid}
    ldap::LDAPConnection

    function MessageChain(handle::Ptr{Cvoid}, ldap::LDAPConnection)
        chain = new(handle, ldap)
        finalizer(destroy!, chain)
        return chain
    end
end

abstract type AbstractMessage end

mutable struct Message{msgtype} <: AbstractMessage
    handle::Ptr{Cvoid}
    id::Int
    chain::MessageChain

    function Message(handle::Ptr{Cvoid}, chain::MessageChain)
        id = ldap_msgid(handle)
        msgtype = LDAPMessageType(ldap_msgtype(handle))
        return new{msgtype}(handle, id, chain)
    end
end

const Entry = Message{LDAP_RES_SEARCH_ENTRY}
const Reference = Message{LDAP_RES_SEARCH_REFERENCE}
const Result = Message{LDAP_RES_SEARCH_RESULT}

struct MessageIterator{T<:AbstractMessage}
    chain::MessageChain
end

#=
typedef struct berval {
    ber_len_t   bv_len; # long
    char        *bv_val;
} BerValue;
=#
struct Berval
    len::Clong
    val::Ptr{UInt8}
end

#=
typedef struct ldapcontrol {
    char *          ldctl_oid;          /* numericoid of control */
    struct berval   ldctl_value;        /* encoded value of control */
    char            ldctl_iscritical;   /* criticality */
} LDAPControl;
=#
struct LDAPControl
    oid::Cstring
    value::Berval
    iscritical::Cchar
end

struct Control
    oid::String
    value::String
    iscritical::Char
end

struct ParsedResult
    errcodep::Cint
    matched::String
    error_message::String
    referrals::Vector{String}
    controls::Vector{Control}
end

mutable struct AttributesIterator
    entry::Entry
    first_ber_element::Ptr{Cvoid}
    first_attribute_name::Union{Nothing, String}

    function AttributesIterator(entry::Entry, first_ber_element::Ptr{Cvoid}, attr::String)
        result = new(entry, first_ber_element, attr)
        if first_ber_element != C_NULL
            finalizer(destroy!, result)
        end
        return result
    end
end
