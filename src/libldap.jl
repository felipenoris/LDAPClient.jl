
#int ldap_is_ldap_url( const char *url )
function ldap_is_ldap_url(url::AbstractString)
    ccall((:ldap_is_ldap_url, libldap), Cint, (Cstring,), url)
end

# int ldap_initialize(LDAP **ldp, char *uri)
function ldap_initialize(ldp_handle_ref::Ref{Ptr{Cvoid}}, uri::AbstractString)
    ccall((:ldap_initialize, libldap), Cint, (Ref{Ptr{Cvoid}}, Cstring), ldp_handle_ref, uri)
end

#char *ldap_err2string( int err );
function ldap_err2string(err::Integer)
    ccall((:ldap_err2string, libldap), Cstring, (Cint,), err)
end

# int ldap_url_parse( const char *url, LDAPURLDesc **ludpp )
function ldap_url_parse(url::AbstractString, ldap_url_desc_handle_ref::Ref{Ptr{LDAPURLDesc}})
    ccall((:ldap_url_parse, libldap), Cint, (Cstring, Ref{Ptr{LDAPURLDesc}}), url, ldap_url_desc_handle_ref)
end

# void ldap_free_urldesc( LDAPURLDesc *ludp );
function ldap_free_urldesc(ldap_url_desc_handle::Ptr{LDAPURLDesc})
    ccall((:ldap_free_urldesc, libldap), Cvoid, (Ptr{LDAPURLDesc},), ldap_url_desc_handle)
end

# int ldap_get_option(LDAP *ld, int option, void *outvalue);
function ldap_get_option(ldp_handle::Ptr{Cvoid}, option::LDAPOption, out_value_ref::Ref{Cint})
    opt_int = Cint(option)
    ccall((:ldap_get_option, libldap), Cint, (Ptr{Cvoid}, Cint, Ref{Cint}), ldp_handle, opt_int, out_value_ref)
end

# int ldap_set_option(LDAP *ld, int option, const void *invalue);
function ldap_set_option(ldp_handle::Ptr{Cvoid}, option::LDAPOption, in_value::T) where {T}
    opt_int = Cint(option)
    in_value_ref = Ref(Cint(in_value))
    ccall((:ldap_set_option, libldap), Cint, (Ptr{Cvoid}, Cint, Ref{Cint}), ldp_handle, opt_int, in_value_ref)
end

# int ldap_simple_bind_s(LDAP *ld, const char *who, const char *passwd);
function ldap_simple_bind_s(ldp_handle::Ptr{Cvoid}, who::AbstractString, password::AbstractString)
    ccall((:ldap_simple_bind_s, libldap), Cint, (Ptr{Cvoid}, Cstring, Cstring), ldp_handle, who, password)
end

# int ldap_unbind_s(LDAP *ld);
function ldap_unbind_s(ldp_handle::Ptr{Cvoid})
    ccall((:ldap_unbind_s, libldap), Cint, (Ptr{Cvoid},), ldp_handle)
end
