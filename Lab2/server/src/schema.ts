import { z } from 'zod';
const text = z.string().trim().min(1).max(200);
const short = z.string().max(1000);
const id = z.string().min(1).max(100);
const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/);
const pace = z.string().regex(/^\d{1,2}:[0-5]\d$/);
export const schemas = {
  notes: z.object({title: text, content: z.string().max(10000).default('')}),
  races: z.object({code: text, title: text, date: text, time, city: text,
    country: z.enum(['moldova','romania']), artwork: z.enum(['vineyard','arch','orhei','stefan','iasiPalace','athenaeum','forest','riverside','parkSteps']),
    venue: text, season: text, distanceFromChisinau: z.number().int().min(0), distances: z.array(z.number().positive()).min(1),
    previewDistance: z.number().positive().nullable().optional(), type: text, status: text, fee: z.number().int().min(0),
    currency: z.enum(['MDL','RON','EUR']), discount: short, organizerNote: short, registrationUrl: z.url()}),
  plans: z.object({raceId: id, reminderDays: z.number().int().min(0).max(365), distance: z.number().positive().nullable(), pace, visibility: z.enum(['private','public'])}),
  offers: z.object({raceId: id, driverName: text, departureTime: time, pickupPoint: text, freeSeats: z.number().int().min(1).max(8), contribution: z.number().int().min(0), departureCity: text, phone: z.string().regex(/^\+?[\d\s()-]{8,20}$/)}),
  requests: z.object({raceId: id, passengerName: text, seats: z.number().int().min(1).max(8), pickupPoint: text, departureCity: text, departureTime: time, phone: z.string().regex(/^\+?[\d\s()-]{8,20}$/)}),
  profiles: z.object({name: text, email: z.email(), city: text, pace, bio: short, preferredDistance: z.number().positive(), seasonGoal: z.number().int().min(1).max(100), avatar: z.number().int().min(0).max(5), appearance: z.enum(['system','light','dark']), publicPlan: z.boolean()}),
};
export type Resource = keyof typeof schemas;
export const registration = z.object({email: z.email().transform(v=>v.toLowerCase()), password: z.string().min(8).max(128), name: text});
export const credentials = z.object({email: z.email().transform(v=>v.toLowerCase()), password: z.string().min(1).max(128)});
