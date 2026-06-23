import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import { UserModel } from '../src/models/user.model';

const MONGO_URL = process.env.MONGO_URL!;

const users = [
  // Center Head
  {
    name: 'Arjun Sharma',
    phone: '+919876543210',
    password: 'Admin@123',
    role: 'center_head' as const,
  },
  // Therapists
  {
    name: 'Priya Mehta',
    phone: '+919876543211',
    password: 'Therapist@1',
    role: 'therapist' as const,
  },
  {
    name: 'Rohan Verma',
    phone: '+919876543212',
    password: 'Therapist@2',
    role: 'therapist' as const,
  },
  {
    name: 'Sneha Kapoor',
    phone: '+919876543213',
    password: 'Therapist@3',
    role: 'therapist' as const,
  },
  {
    name: 'Amit Joshi',
    phone: '+919876543214',
    password: 'Therapist@4',
    role: 'therapist' as const,
  },
  // Parents
  {
    name: 'Sunita Rao',
    phone: '+919876543215',
    password: 'Parent@1234',
    role: 'parent' as const,
  },
  {
    name: 'Vikram Singh',
    phone: '+919876543216',
    password: 'Parent@1234',
    role: 'parent' as const,
  },
  {
    name: 'Deepa Nair',
    phone: '+919876543217',
    password: 'Parent@1234',
    role: 'parent' as const,
  },
  {
    name: 'Rajesh Patel',
    phone: '+919876543218',
    password: 'Parent@1234',
    role: 'parent' as const,
  },
  {
    name: 'Kavya Reddy',
    phone: '+919876543219',
    password: 'Parent@1234',
    role: 'parent' as const,
  },
];

async function seed() {
  await mongoose.connect(MONGO_URL, { serverSelectionTimeoutMS: 10000 });
  console.log('Connected to MongoDB');

  let created = 0;
  let skipped = 0;

  for (const u of users) {
    const exists = await UserModel.findOne({ phone: u.phone });
    if (exists) {
      console.log(`  skip  ${u.role.padEnd(12)} ${u.name} (${u.phone})`);
      skipped++;
      continue;
    }
    const password_hash = await bcrypt.hash(u.password, 12);
    await UserModel.create({ name: u.name, phone: u.phone, password_hash, role: u.role });
    console.log(`  added ${u.role.padEnd(12)} ${u.name} (${u.phone})`);
    created++;
  }

  console.log(`\nDone — ${created} created, ${skipped} already existed.`);
  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
