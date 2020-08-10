
using Test

import LDAPClient

@testset "URL" begin

    @testset "Equality" begin
        sample_url_a = LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", ["a", "b"] , 0, nothing, ["a", "b"], 0)
        sample_url_b = LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", ["a", "b"] , 0, nothing, ["a", "b"], 0)
        @test sample_url_a == sample_url_b

        sample_url_c = LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", Vector{String}(), 0, nothing, ["a", "b"], 0)
        sample_url_d = LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", Vector{String}(), 0, nothing, ["a", "b"], 0)
        @test sample_url_c == sample_url_d

        @test sample_url_a != sample_url_c
    end

    url_strings = [
        "ldap://ds.example.com:389/dc=example,dc=com",
        "ldap://ds.example.com:389",
        "ldap://ds.example.com:389/dc=example,dc=com?givenName,sn,cn?sub?(uid=john.doe)"
    ]

    expected_urls = [
        LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", Vector{String}(), 0, nothing, Vector{String}(), 0),
        LDAPClient.URL("ldap", "ds.example.com", 389, nothing, Vector{String}(), 0, nothing, Vector{String}(), 0),
        LDAPClient.URL("ldap", "ds.example.com", 389, "dc=example,dc=com", ["givenName", "sn", "cn"], 2, "(uid=john.doe)", Vector{String}(), 0)
    ]

    @assert length(url_strings) == length(expected_urls)

    for i in 1:length(url_strings)
        url_s = url_strings[i]
        @test LDAPClient.is_ldap_url(url_s)
        url = LDAPClient.URL(url_s)
        @test url == expected_urls[i]
    end

    @test !LDAPClient.is_ldap_url("https://github.com")
end

@testset "LDAPConnection" begin
    ldap = LDAPClient.LDAPConnection("ldap://ds.example.com:389")
    @test LDAPClient.get_protocol_version(ldap) == LDAPClient.LDAP_VERSION3

    ldap = LDAPClient.LDAPConnection("ldap://ds.example.com:389", protocol=LDAPClient.LDAP_VERSION2)
    @test LDAPClient.get_protocol_version(ldap) == LDAPClient.LDAP_VERSION2

    # result = LDAPClient.authenticate(uri, "user", "pass")
end
