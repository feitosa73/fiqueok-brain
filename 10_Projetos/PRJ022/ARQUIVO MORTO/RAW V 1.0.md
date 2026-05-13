<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3" xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3" xmlns:icfs="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/resource-schema-3" xmlns:org="http://midpoint.evolveum.com/xml/ns/public/common/org-3" xmlns:q="http://prism.evolveum.com/xml/ns/public/query-3" xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3" xmlns:t="http://prism.evolveum.com/xml/ns/public/types-3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" oid="2fe1b874-8a5f-41d2-8ea9-9f4224c5f327" version="5">
    <_metadata id="1">
        <storage>
            <createTimestamp>2026-05-04T00:28:45.590Z</createTimestamp>
            <creatorRef oid="55eff3d1-16f8-4584-aed5-cfc23f9d7af3" relation="org:default" type="c:UserType">
                <!-- paulo -->
            </creatorRef>
            <createChannel>http://midpoint.evolveum.com/xml/ns/public/common/channels-3#user</createChannel>
            <modifyTimestamp>2026-05-04T00:47:04.564Z</modifyTimestamp>
            <modifierRef oid="55eff3d1-16f8-4584-aed5-cfc23f9d7af3" relation="org:default" type="c:UserType">
                <!-- paulo -->
            </modifierRef>
            <modifyChannel>http://midpoint.evolveum.com/xml/ns/public/common/channels-3#user</modifyChannel>
        </storage>
        <process>
            <requestTimestamp>2026-05-04T00:28:45.563Z</requestTimestamp>
            <requestorRef oid="55eff3d1-16f8-4584-aed5-cfc23f9d7af3" relation="org:default" type="c:UserType">
                <!-- paulo -->
            </requestorRef>
        </process>
    </_metadata>
    <name>Fiqueok HR (Shadow API CSV)</name>
    <lifecycleState>active</lifecycleState>
    <iteration>0</iteration>
    <iterationToken/>
    <operationalState>
        <lastAvailabilityStatus>up</lastAvailabilityStatus>
        <message>Status set to UP because resource schema was successfully fetched</message>
        <timestamp>2026-05-04T00:28:45.627Z</timestamp>
        <nodeId>DefaultNode</nodeId>
    </operationalState>
    <operationalStateHistory id="4">
        <lastAvailabilityStatus>up</lastAvailabilityStatus>
        <message>Status set to UP because resource schema was successfully fetched</message>
        <timestamp>2026-05-04T00:28:45.627Z</timestamp>
        <nodeId>DefaultNode</nodeId>
    </operationalStateHistory>
    <connectorRef oid="ea8bf51d-2133-4c42-a82e-df30020948d1" relation="org:default" type="c:ConnectorType">
        <!-- ConnId com.evolveum.polygon.connector.csv.CsvConnector v2.9 -->
    </connectorRef>
    <connectorConfiguration xmlns:icfc="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3">
        <icfc:configurationProperties xmlns:cfg="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/bundle/com.evolveum.polygon.connector-csv/com.evolveum.polygon.connector.csv.CsvConnector">
            <cfg:multivalueDelimiter>_</cfg:multivalueDelimiter>
            <cfg:fieldDelimiter>,</cfg:fieldDelimiter>
            <cfg:filePath>/opt/midpoint/var/hr_export.csv</cfg:filePath>
            <cfg:nameAttribute>employee_id</cfg:nameAttribute>
            <cfg:uniqueAttribute>employee_id</cfg:uniqueAttribute>
        </icfc:configurationProperties>
    </connectorConfiguration>
    <schema>
        <cachingMetadata>
            <retrievalTimestamp>2026-05-04T00:28:45.625Z</retrievalTimestamp>
            <serialNumber>f0d7c8d52a57070a-1b501e592687016a</serialNumber>
        </cachingMetadata>
        <generationConstraints>
            <generateObjectClass>ri:AccountObjectClass</generateObjectClass>
        </generationConstraints>
        <definition>
            <xsd:schema xmlns:a="http://prism.evolveum.com/xml/ns/public/annotation-3" xmlns:ra="http://midpoint.evolveum.com/xml/ns/public/resource/annotation-3" xmlns:tns="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3" xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified" targetNamespace="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">
                <xsd:import namespace="http://prism.evolveum.com/xml/ns/public/annotation-3"/>
                <xsd:import namespace="http://midpoint.evolveum.com/xml/ns/public/resource/annotation-3"/>
                <xsd:complexType name="AccountObjectClass">
                    <xsd:annotation>
                        <xsd:appinfo>
                            <a:container>true</a:container>
                            <ra:resourceObject>true</ra:resourceObject>
                            <ra:nativeObjectClass>__ACCOUNT__</ra:nativeObjectClass>
                            <ra:default>true</ra:default>
                            <ra:auxiliary>false</ra:auxiliary>
                            <ra:embedded>false</ra:embedded>
                            <ra:namingAttribute>ri:employee_id</ra:namingAttribute>
                            <ra:displayNameAttribute>ri:employee_id</ra:displayNameAttribute>
                            <ra:identifier>ri:employee_id</ra:identifier>
                        </xsd:appinfo>
                    </xsd:annotation>
                    <xsd:sequence>
                        <xsd:element minOccurs="0" name="emp_number" type="xsd:string">
                            <xsd:annotation>
                                <xsd:appinfo>
                                    <a:displayOrder>120</a:displayOrder>
                                    <ra:nativeAttributeName>emp_number</ra:nativeAttributeName>
                                    <ra:frameworkAttributeName>emp_number</ra:frameworkAttributeName>
                                    <ra:returnedByDefault>true</ra:returnedByDefault>
                                </xsd:appinfo>
                            </xsd:annotation>
                        </xsd:element>
                        <xsd:element name="employee_id" type="xsd:string">
                            <xsd:annotation>
                                <xsd:appinfo>
                                    <a:displayOrder>100</a:displayOrder>
                                    <ra:nativeAttributeName>employee_id</ra:nativeAttributeName>
                                    <ra:frameworkAttributeName>__NAME__</ra:frameworkAttributeName>
                                    <ra:returnedByDefault>true</ra:returnedByDefault>
                                </xsd:appinfo>
                            </xsd:annotation>
                        </xsd:element>
                        <xsd:element minOccurs="0" name="last_name" type="xsd:string">
                            <xsd:annotation>
                                <xsd:appinfo>
                                    <a:displayOrder>130</a:displayOrder>
                                    <ra:nativeAttributeName>last_name</ra:nativeAttributeName>
                                    <ra:frameworkAttributeName>last_name</ra:frameworkAttributeName>
                                    <ra:returnedByDefault>true</ra:returnedByDefault>
                                </xsd:appinfo>
                            </xsd:annotation>
                        </xsd:element>
                        <xsd:element minOccurs="0" name="first_name" type="xsd:string">
                            <xsd:annotation>
                                <xsd:appinfo>
                                    <a:displayOrder>140</a:displayOrder>
                                    <ra:nativeAttributeName>first_name</ra:nativeAttributeName>
                                    <ra:frameworkAttributeName>first_name</ra:frameworkAttributeName>
                                    <ra:returnedByDefault>true</ra:returnedByDefault>
                                </xsd:appinfo>
                            </xsd:annotation>
                        </xsd:element>
                    </xsd:sequence>
                </xsd:complexType>
            </xsd:schema>
        </definition>
    </schema>
    <schemaHandling>
        <objectType id="5">
            <kind>account</kind>
            <intent>default</intent>
            <displayName>Colaborador HR`</displayName>
            <delineation>
                <objectClass>ri:AccountObjectClass</objectClass>
            </delineation>
            <focus>
                <type>c:UserType</type>
            </focus>
            <attribute id="6">
                <ref>ri:employee_id</ref>
                <inbound id="7">
                    <name>Mapeamento de Nome de Sistema</name>
                    <strength>strong</strength>
                    <target>
                        <path>name</path>
                    </target>
                </inbound>
                <inbound id="8">
                    <name>Mapeamento de Matrícula</name>
                    <strength>strong</strength>
                    <target>
                        <path>personalNumber</path>
                    </target>
                </inbound>
            </attribute>
            <attribute id="9">
                <ref>ri:first_name</ref>
                <inbound id="10">
                    <name>Mapeamento de Primeiro Nome</name>
                    <strength>strong</strength>
                    <target>
                        <path>givenName</path>
                    </target>
                </inbound>
            </attribute>
            <attribute id="11">
                <ref>ri:last_name</ref>
                <inbound id="12">
                    <name>Mapeamento de Sobrenome</name>
                    <strength>strong</strength>
                    <target>
                        <path>familyName</path>
                    </target>
                </inbound>
            </attribute>
            <correlation>
                <correlators>
                    <items id="13">
                        <name>Correlacao_Matricula</name>
                        <enabled>true</enabled>
                        <item id="14">
                            <ref>personalNumber</ref>
                        </item>
                    </items>
                </correlators>
            </correlation>
        </objectType>
    </schemaHandling>
    <capabilities>
        <cachingMetadata>
            <retrievalTimestamp>2026-05-04T00:28:45.620Z</retrievalTimestamp>
            <serialNumber>9b3eb6e7e0058e47-d66224629d7ee7b5</serialNumber>
        </cachingMetadata>
        <native xmlns:cap="http://midpoint.evolveum.com/xml/ns/public/resource/capabilities-3">
            <cap:schema/>
            <cap:discoverConfiguration/>
            <cap:liveSync/>
            <cap:create/>
            <cap:read>
                <cap:returnDefaultAttributesOption>false</cap:returnDefaultAttributesOption>
            </cap:read>
            <cap:update>
                <cap:addRemoveAttributeValues>true</cap:addRemoveAttributeValues>
            </cap:update>
            <cap:delete/>
            <cap:testConnection/>
            <cap:script>
                <cap:host id="2">
                    <cap:type>resource</cap:type>
                </cap:host>
                <cap:host id="3">
                    <cap:type>connector</cap:type>
                </cap:host>
            </cap:script>
        </native>
    </capabilities>
</resource>
