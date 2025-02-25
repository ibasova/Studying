// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "contactmodel.h"

ContactModel::ContactModel(QObject *parent ) : QAbstractListModel(parent)
{
    m_contacts.append({ "Amir Rodrigis", "Ulica Severa 42", "Yurga", "0363 0510499", "Integra", "PM" });
    m_contacts.append({ "Angel Hogan", "Chapel St. 368 ", "Clearwater", "0311 1823993" });
    m_contacts.append({ "Felicia Patton", "Annadale Lane 2", "Knoxville", "0368 1244494" });
    m_contacts.append({ "Henrietta Chavez", "Via Volto San Luca 3", "Piobesi Torinese", "0399 2826994" });
    m_contacts.append({ "Harvey Chandler", "North Squaw Creek 11", "Madisonville", "0343 1244492" });
    m_contacts.append({ "Miguel Gomez", "Wild Rose Street 13", "Trussville" , "0343 9826996" });
    m_contacts.append({ "Norma Rodriguez", " Glen Eagles Street  53", "Buffalo", "0241 5826596" });
    m_contacts.append({ "Shelia Ramirez", "East Miller Ave 68", "Pickerington", "0346 4844556" });
    m_contacts.append({ "Stephanie Moss", "Piazza Trieste e Trento 77", "Roata Chiusani", "0363 0510490" });
}

int ContactModel::rowCount(const QModelIndex &) const
{
    return m_contacts.count();
}

QVariant ContactModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < rowCount())
        switch (role) {
        case FullNameRole: return m_contacts.at(index.row()).fullName;
        case AddressRole: return m_contacts.at(index.row()).address;
        case CityRole: return m_contacts.at(index.row()).city;
        case NumberRole: return m_contacts.at(index.row()).number;
        case CompanyRole: return m_contacts.at(index.row()).company;
        case PositionRole: return m_contacts.at(index.row()).position;
        default: return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> ContactModel::roleNames() const
{
    static const QHash<int, QByteArray> roles {
        { FullNameRole, "fullName" },
        { AddressRole, "address" },
        { CityRole, "city" },
        { NumberRole, "number" },
        { CompanyRole, "company" },
        { PositionRole, "position" }
    };
    return roles;
}

QVariantMap ContactModel::get(int row) const
{
    const Contact contact = m_contacts.value(row);
    return {
        {"fullName", contact.fullName},
        {"address", contact.address},
        {"city", contact.city},
        {"number", contact.number},
        {"company", contact.company},
        {"position", contact.position}
    };
}

void ContactModel::append(const QString &fullName, const QString &address, const QString &city,
                          const QString &number, const QString &company, const QString &position)
{
    int row = 0;
    while (row < m_contacts.count() && fullName > m_contacts.at(row).fullName)
        ++row;
    beginInsertRows(QModelIndex(), row, row);
    m_contacts.insert(row, {fullName, address, city, number, company, position});
    endInsertRows();
}

void ContactModel::set(int row, const QString &fullName, const QString &address, const QString &city,
                       const QString &number, const QString &company, const QString &position)
{
    if (row < 0 || row >= m_contacts.count())
        return;

    m_contacts.replace(row, { fullName, address, city, number, company, position });
    dataChanged(index(row, 0), index(row, 0), { FullNameRole, AddressRole, CityRole, NumberRole, CompanyRole, PositionRole });
}

void ContactModel::remove(int row)
{
    if (row < 0 || row >= m_contacts.count())
        return;

    beginRemoveRows(QModelIndex(), row, row);
    m_contacts.removeAt(row);
    endRemoveRows();
}
