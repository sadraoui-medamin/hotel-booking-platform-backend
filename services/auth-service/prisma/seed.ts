import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  const masterPassword = await bcrypt.hash('Master123!', 10);
  const adminPassword = await bcrypt.hash('Admin123!', 10);
  const supportPassword = await bcrypt.hash('Support123!', 10);
  const reporterPassword = await bcrypt.hash('Reporter123!', 10);
  const userPassword = await bcrypt.hash('User123!', 10);

  const master = await prisma.user.upsert({
    where: { email: 'master@hotel.com' },
    update: {},
    create: {
      email: 'master@hotel.com',
      password: masterPassword,
      firstName: 'Master',
      lastName: 'Admin',
      role: UserRole.MASTER,
    },
  });

  const admin = await prisma.user.upsert({
    where: { email: 'admin@hotel.com' },
    update: {},
    create: {
      email: 'admin@hotel.com',
      password: adminPassword,
      firstName: 'System',
      lastName: 'Admin',
      role: UserRole.ADMIN,
      createdBy: master.id,
    },
  });

  const support = await prisma.user.upsert({
    where: { email: 'support@hotel.com' },
    update: {},
    create: {
      email: 'support@hotel.com',
      password: supportPassword,
      firstName: 'Support',
      lastName: 'Team',
      role: UserRole.SUPPORT,
      createdBy: admin.id,
    },
  });

  const reporter = await prisma.user.upsert({
    where: { email: 'reporter@hotel.com' },
    update: {},
    create: {
      email: 'reporter@hotel.com',
      password: reporterPassword,
      firstName: 'Finance',
      lastName: 'Reporter',
      role: UserRole.REPORTER,
      createdBy: admin.id,
    },
  });

  const user = await prisma.user.upsert({
    where: { email: 'user@test.com' },
    update: {},
    create: {
      email: 'user@test.com',
      password: userPassword,
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.USER,
    },
  });

  console.log('✅ Seeding completed!');
  console.log('Created users:', { master, admin, support, reporter, user });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });